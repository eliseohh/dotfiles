# dotfiles

Personal configuration files for my Linux development environment
(Fedora + i3 + Zsh + Neovim), oriented toward Go and web (`templ` / HTMX /
TailwindCSS) development.

## Stack

| Area        | Tool                                                                 |
|-------------|----------------------------------------------------------------------|
| OS / distro | Fedora (Zsh uses the `dnf` plugin)                                    |
| WM          | i3 (i3-gaps)                                                          |
| Bar         | i3status                                                             |
| Shell       | Zsh + [oh-my-zsh](https://ohmyz.sh/) (`agnosterzak` theme)            |
| Editor      | Neovim (vim-plug) — native LSP, `nvim-cmp`, Treesitter, LuaSnip      |
| CLI tools   | `fzf`, `lsd`, `fastfetch`, `xclip`, `tmux`                           |

## Repository layout

```
.zshrc                     Zsh + oh-my-zsh config (aliases, PATH, plugins)
.i3gapscfg                 i3 window manager config      → ~/.config/i3/config
.i3status                  i3status bar config           → ~/.config/i3status/config
.vimrc                     Neovim entry config (vim-plug, LSP, cmp, colors)
.vim/plugin/               Modular Neovim Lua config, auto-loaded by .vimrc:
  ├─ cmp.lua               nvim-cmp autocompletion + ghost text
  ├─ templ.lua             Mason + LSP servers, templ fmt/generate, keymaps, LuaSnip
  ├─ go_syntax.lua         vim-go highlight settings
  ├─ go_formatter.lua      Format Go on save (gofmt / vim-go)
  ├─ lua_formatter.lua     lua_ls LSP + format on save
  └─ error_formatter.lua   Diagnostic styling + format-on-save helpers
```

## Requirements

- **Neovim 0.11+** (the Lua config uses the `vim.lsp.config` API)
- [vim-plug](https://github.com/junegunn/vim-plug) (`:PlugInstall` on first run)
- **Node.js** (for the legacy coc.nvim config / some language servers)
- **Go** toolchain + [`templ`](https://templ.guide/) for web work
- `fzf`, `ripgrep`/`ag` (for `:Ag`), `lsd`, `fastfetch`, `xclip`
- i3, i3status, `feh` (wallpaper), `i3lock`, `nm-applet`, PulseAudio (`pactl`)

Language servers are installed automatically via **Mason**:
`html`, `ts_ls`, `gopls`, `tailwindcss`, `cssls`, `emmet_ls`, `lua_ls`.

## Installation

Clone and symlink the files into place:

```sh
git clone https://github.com/eliseohh/dotfiles.git ~/dotfiles
cd ~/dotfiles

ln -sf "$PWD/.zshrc"   ~/.zshrc
ln -sf "$PWD/.vimrc"   ~/.vimrc
mkdir -p ~/.vim && ln -sf "$PWD/.vim/plugin" ~/.vim/plugin

mkdir -p ~/.config/i3 ~/.config/i3status
ln -sf "$PWD/.i3gapscfg" ~/.config/i3/config
ln -sf "$PWD/.i3status"  ~/.config/i3status/config
```

Then open Neovim and run `:PlugInstall`.

> **Neovim note:** this config uses the classic `~/.vimrc` + `~/.vim/` paths.
> If Neovim doesn't pick them up, point `~/.config/nvim/init.vim` at it:
> `echo 'source ~/.vimrc' > ~/.config/nvim/init.vim`

## Notable keybindings

**i3** (`$mod` = Super):

| Keys                     | Action                          |
|--------------------------|---------------------------------|
| `$mod+Return`            | Terminal (termite)              |
| `$mod+d`                 | App launcher (i3-dmenu-desktop) |
| `$mod+j/k/l/;`           | Focus left/down/up/right        |
| `$mod+Shift+q`           | Kill window                     |
| `$mod+1..0`              | Switch workspace                |
| `$mod+Shift+e`           | Exit i3                         |

**Neovim** (leader = `\`):

| Keys           | Action                        |
|----------------|-------------------------------|
| `\f`           | FZF file finder               |
| `\b`           | Buffers                       |
| `\n` / `Ctrl-n`| NERDTree focus / toggle       |
| `gd` / `gr`    | LSP definition / references   |
| `K`            | LSP hover                     |
| `\lf`          | Format buffer                 |
| `\tg`          | `templ generate` + LSP restart|

## Notes

- `.i3gapscfg` hardcodes a wallpaper path (`/home/eliseo/Images/…`) — adjust it
  for your machine.
