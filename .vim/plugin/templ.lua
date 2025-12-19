-- ========================================== --
--               TEMPL.LUA                     --
--    Configuración completa Neovim 0.11+     --
-- ========================================== --

vim.g.mapleader = "\\"

-- ================================ --
-- Opciones básicas
-- ================================ --
vim.o.number = true
vim.o.visualbell = true
vim.o.encoding = "utf-8"
vim.o.formatoptions = "tcqrn"
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.backspace = "indent,eol,start"
vim.o.hidden = true
vim.o.ttyfast = true
vim.o.laststatus = 2
vim.o.showmode = true
vim.o.showcmd = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showmatch = true
vim.o.matchpairs = vim.o.matchpairs .. ",<:>"
vim.o.list = true
vim.o.listchars = "eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣"

-- ================================ --
-- Keymaps generales
-- ================================ --
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- FZF
vim.keymap.set("n", "<leader>f", ":FZF<CR>")
vim.keymap.set("n", "<leader>b", ":Buffers<CR>")
vim.keymap.set("n", "<leader>a", ":Ag<CR>")
vim.keymap.set("n", "<leader>l", ":Lines<CR>")
vim.keymap.set("n", "<leader>co", ":Commands<CR>")

-- NERDTree
vim.keymap.set("n", "<leader>n", ":NERDTreeFocus<CR>")
vim.keymap.set("n", "<C-n>", ":NERDTree<CR>")
vim.keymap.set("n", "<C-t>", ":NERDTreeToggle<CR>")
vim.keymap.set("n", "<C-f>", ":NERDTreeFind<CR>")

-- ================================ --
-- Función para verificar binarios
-- ================================ --
local function is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

-- ================================ --
-- Capacidades LSP (nvim-cmp)
-- ================================ --
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- ================================ --
-- Función para mostrar errores en minibuffer
-- ================================ --
local function show_error(err)
  vim.notify(err, vim.log.levels.ERROR)
end

-- ================================ --
-- Formateo custom
-- ================================ --
-- Guarda el job activo por buffer para evitar spam
local templ_fmt_job = {}

local function custom_format()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == "" then return end

  if vim.bo[bufnr].filetype ~= "templ" then
    if vim.lsp.buf.format then vim.lsp.buf.format({ bufnr = bufnr }) end
    return
  end

  if not is_executable("templ") then
    show_error("No se encontró 'templ' para formatear")
    return
  end

  if not vim.loop.fs_stat(filename) then
    vim.notify("Archivo no existe en disco: " .. filename, vim.log.levels.ERROR, { title = "templ fmt" })
    return
  end

  vim.fn.jobstart({ "templ", "fmt", filename }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local msg = table.concat(data, "\n"):gsub("\n+$", "")
        if msg ~= "" then
          vim.schedule(function()
            vim.notify(msg, vim.log.levels.ERROR, { title = "templ fmt" })
          end)
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("templ fmt falló (exit " .. tostring(code) .. ")", vim.log.levels.ERROR, { title = "templ fmt" })
          return
        end
        if vim.api.nvim_buf_is_valid(bufnr)
            and vim.api.nvim_get_current_buf() == bufnr
            and not vim.bo[bufnr].modified
        then
          vim.cmd("checktime")
        end
      end)
    end,
  })
end

-- ================================ --
-- Formateo al guardar templ
-- ================================ --

local templ_fmt_running = {}
local templ_fmt_timer = {}

local function custom_format_templ(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then return end
  if vim.bo[bufnr].filetype ~= "templ" then return end
  if not is_executable("templ") then
    vim.notify("No se encontró 'templ' para formatear", vim.log.levels.ERROR, { title = "templ fmt" })
    return
  end
  if not vim.loop.fs_stat(filename) then
    vim.notify("Archivo no existe en disco: " .. filename, vim.log.levels.ERROR, { title = "templ fmt" })
    return
  end

  if templ_fmt_running[bufnr] then return end
  templ_fmt_running[bufnr] = true

  vim.fn.jobstart({ "templ", "fmt", filename }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local msg = table.concat(data, "\n"):gsub("\n+$", "")
        if msg ~= "" then
          vim.schedule(function()
            vim.notify(msg, vim.log.levels.ERROR, { title = "templ fmt" })
          end)
        end
      end
    end,
    on_exit = function(_, code)
      templ_fmt_running[bufnr] = nil
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("templ fmt falló (exit " .. tostring(code) .. ")", vim.log.levels.ERROR, { title = "templ fmt" })
          return
        end
        -- Si sigues en ese buffer y NO hay cambios locales, recarga desde disco
        if vim.api.nvim_buf_is_valid(bufnr)
            and vim.api.nvim_get_current_buf() == bufnr
            and not vim.bo[bufnr].modified
        then
          vim.cmd("silent! checktime")
          vim.cmd("silent! edit")
        end
      end)
    end,
  })
end

-- ================================ --
-- Función on_attach para LSP
-- ================================ --
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  -- Formateo manual
  vim.keymap.set("n", "<leader>lf", custom_format, opts)

  -- Navegación LSP
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  -- Diagnósticos flotantes
  vim.keymap.set("n", "<leader>e", function()
    vim.diagnostic.open_float(nil, { focus = false })
  end, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  -- Autoformateo al guardar
  -- ✅ Autoformateo al guardar (POST, con debounce)
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.templ",
    callback = function(args)
      local bufnr = args.buf
      -- debounce 150ms para evitar doble disparo
      if templ_fmt_timer[bufnr] then
        templ_fmt_timer[bufnr]:stop()
        templ_fmt_timer[bufnr]:close()
      end
      local t = vim.loop.new_timer()
      templ_fmt_timer[bufnr] = t
      t:start(150, 0, function()
        t:stop()
        t:close()
        templ_fmt_timer[bufnr] = nil
        vim.schedule(function()
          custom_format_templ(bufnr)
        end)
      end)
    end,
  })
end

-- ================================ --
-- Mason + LSPConfig
-- ================================ --
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "html",
    "ts_ls",
    "gopls",
    "tailwindcss",
    "cssls",
    "emmet_ls",
    "lua_ls",
  },
  automatic_installation = true,
})

-- Configuración común
local common_config = {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- ================================ --
-- Servidores LSP
-- ================================ --
vim.lsp.config("tailwindcss", vim.tbl_extend("force", common_config, {
  filetypes = { "templ", "html", "javascript", "typescript", "react", "astro" },
  settings = { tailwindCSS = { includeLanguages = { templ = "html" } } },
}))

vim.lsp.config("html", vim.tbl_extend("force", common_config, { filetypes = { "html", "templ", "htmx" } }))
vim.lsp.config("emmet_ls", vim.tbl_extend("force", common_config, {
  filetypes = { "html", "templ", "htmx" },
  init_options = { html = { options = { ["bem.enabled"] = true } } },
}))
vim.lsp.config("cssls", vim.tbl_extend("force", common_config, { filetypes = { "css", "scss", "templ" } }))
vim.lsp.config("ts_ls", common_config)
vim.lsp.config("gopls", common_config)

-- Opcionales
local optional_servers = {
  { name = "ccls",  cmd = "ccls" },
  { name = "cmake", cmd = "cmake-language-server" },
}
for _, server in ipairs(optional_servers) do
  if is_executable(server.cmd) then
    vim.lsp.config(server.name, common_config)
  else
    vim.notify("No se encontró LSP " .. server.name .. " (" .. server.cmd .. ")", vim.log.levels.WARN)
  end
end

-- ================================ --
-- Snippets LuaSnip
-- ================================ --
local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_luasnip then
  require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })

  luasnip.add_snippets("templ", {
    luasnip.snippet("if", {
      luasnip.text_node("{% if "),
      luasnip.insert_node(1, "condition"),
      luasnip.text_node(" %}"),
      luasnip.insert_node(2, ""),
      luasnip.text_node("{% endif %}"),
    }),
  })
else
  show_error("LuaSnip no está instalado. Snippets deshabilitados.")
end

-- ================================ --
-- Mensaje de confirmación
-- ================================ --
vim.notify("Neovim listo para Templ, HTML, CSS, HTMX, TailwindCSS y Emmet!", vim.log.levels.INFO)
