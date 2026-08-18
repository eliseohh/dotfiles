;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org-notes/")

;; org-roam + org-roam-ui  (single source of truth — do NOT also set this in custom.el)
(setq org-roam-directory (file-truename "~/org-notes/"))
(after! org-roam-ui
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t))

;; SPC X captures land in the inbox — a file inside the synced folder
(setq +org-capture-todo-file "inbox.org"
      +org-capture-notes-file "inbox.org")

;; ── Native compilation on Windows (added during perf setup) ─────────────
;; This Emacs 30.2 build (MSVCRT, MSYS2 gcc-14.2 runtime) bundles libgccjit's
;; dependencies but not libgccjit itself.  A matching libgccjit-0.dll was
;; placed in w64devkit/bin, and .eln files are linked with w64devkit's
;; gcc/as/ld.  Point the driver at w64devkit's CRT objects + libgcc (plus a
;; libgcc_s.a shim, since w64devkit ships only a static libgcc).  This makes
;; native-comp self-contained even if the LIBRARY_PATH env var is cleared.
(when (eq system-type 'windows-nt)
  (let ((gcclib (car (last (file-expand-wildcards
                            "C:/C/w64devkit/lib/gcc/x86_64-w64-mingw32/*")))))
    (when (and gcclib (file-exists-p "C:/C/w64devkit/lib/dllcrt2.o"))
      (setenv "LIBRARY_PATH"
              (mapconcat #'identity
                         (list "C:/C/w64devkit/lib" gcclib)
                         path-separator)))))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;; ── Cross-device sync hygiene: Windows (here) ⇄ Boox Lumi 2 (Linux) ──────
;; Notes in `org-directory' are edited on both machines, so save them with
;; Unix (LF) endings and keep foreign temp files out of agenda + org-roam.
;;
;; Emacs' own clutter is already handled by Doom: `make-backup-files' and
;; `create-lockfiles' are nil (no `foo.org~' / `.#foo.org'), and auto-saves
;; (`#foo.org#') are redirected into the cache dir — none touch ~/org-notes/.
;; What we defend against here are the temp files the Boox note app and its
;; sync client leave behind while you write on the tablet.

;; 1. Save org files with Unix (LF) line endings (no CRLF, no BOM).
(add-hook 'org-mode-hook
          (defun +org-unix-line-endings-h ()
            "Write org buffers with LF EOL so they render cleanly on Linux/Boox."
            (setq buffer-file-coding-system 'utf-8-unix)))

;; 2. Only treat *real* notes as agenda files. A note is `foo.org'; skip any
;;    basename starting with `.', `#' or `~' — i.e. `.#foo.org' (lock),
;;    `#foo.org#' (auto-save) and `~foo.org' (Boox/temp scratch).
(defun +org-refresh-agenda-files-h (&rest _)
  "Rescan `org-directory' for agenda files.
`directory-files-recursively' only snapshots the tree once, so files
or folders created after startup (e.g. a freshly synced `personal/agenda.org')
stay invisible until a reload. Re-run it before every agenda build so new
notes show up automatically."
  (setq org-agenda-files
        (directory-files-recursively org-directory "\\`[^.#~].*\\.org\\'")))

;; Build the list once now, and refresh it before each agenda/todo view.
(+org-refresh-agenda-files-h)
(advice-add 'org-agenda    :before #'+org-refresh-agenda-files-h)
(advice-add 'org-todo-list :before #'+org-refresh-agenda-files-h)

;; 3. Apply the same exclusions to org-roam's file indexer (matched against
;;    the path relative to `org-roam-directory'), keeping org-roam's defaults.
(after! org-roam
  (setq org-roam-file-exclude-regexp
        (append (ensure-list org-roam-file-exclude-regexp)
                '("\\(?:\\`\\|/\\)[.#~][^/]*\\'"  ; name starts with . # or ~
                  "~\\'"))))                       ; …or ends with ~ (backups)
