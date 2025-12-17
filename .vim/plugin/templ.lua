-- ========================================== --
--               INIT.LUA                     --
--        Configuración completa Templ       --
--        Neovim 0.11+ + Mason + Snippets    --
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
-- Capacidades LSP (para nvim-cmp)
-- ================================ --
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- ================================ --
-- Formateo custom para *.templ
-- ================================ --
local custom_format = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if vim.bo.filetype == "templ" then
        if is_executable("templ") then
            vim.fn.jobstart("templ fmt " .. vim.fn.shellescape(filename), {
                on_exit = function()
                    if vim.api.nvim_get_current_buf() == bufnr then
                        vim.cmd('e!')
                    end
                end,
            })
        else
            vim.notify("No se encontró 'templ' para formatear", vim.log.levels.WARN)
        end
    else
        if vim.lsp.buf.format then
            vim.lsp.buf.format()
        end
    end
end

-- ================================ --
-- Función on_attach para LSP
-- ================================ --
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    -- Formateo
    vim.keymap.set("n", "<leader>lf", custom_format, opts)

    -- Navegación LSP
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    -- Autoformateo al guardar
    vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
            custom_format()
        end,
    })
end

-- ================================ --
-- Setup Mason y Mason-LSPConfig
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
    },
    automatic_installation = true,
})

-- ================================ --
-- Configuración común para LSPs
-- ================================ --
local common_config = {
    on_attach = on_attach,
    capabilities = capabilities,
}

-- ================================ --
-- TailwindCSS
-- ================================ --
vim.lsp.config("tailwindcss", vim.tbl_extend("force", common_config, {
    filetypes = { "templ", "html", "javascript", "typescript", "react", "astro" },
    settings = {
        tailwindCSS = {
            includeLanguages = { templ = "html" },
        },
    },
}))

-- ================================ --
-- HTML (soporte templ + HTMX)
-- ================================ --
vim.lsp.config("html", vim.tbl_extend("force", common_config, {
    filetypes = { "html", "templ", "htmx" },
}))

-- ================================ --
-- Emmet LSP para autocompletar HTML/CSS dentro de templ
-- ================================ --
vim.lsp.config("emmet_ls", vim.tbl_extend("force", common_config, {
    filetypes = { "html", "templ", "htmx" },
    init_options = {
        html = { options = { ["bem.enabled"] = true } },
    },
}))

-- ================================ --
-- CSS LSP
-- ================================ --
vim.lsp.config("cssls", vim.tbl_extend("force", common_config, {
    filetypes = { "css", "scss", "templ" },
}))

-- ================================ --
-- TypeScript / JavaScript
-- ================================ --
vim.lsp.config("ts_ls", common_config)

-- ================================ --
-- Go
-- ================================ --
vim.lsp.config("gopls", common_config)

-- ================================ --
-- Servidores opcionales: ccls y cmake
-- ================================ --
local optional_servers = {
    { name = "ccls", cmd = "ccls" },
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
-- Snippets Templ
-- ================================ --
local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_luasnip then
    require("luasnip.loaders.from_vscode").lazy_load({
        paths = { "./snippets" },
    })

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
    vim.notify("LuaSnip no está instalado. Los snippets no estarán disponibles", vim.log.levels.WARN)
end

-- ================================ --
-- Mensaje de confirmación
-- ================================ --
vim.notify("Neovim listo para Templ con HTML, CSS, HTMX, TailwindCSS y Emmet!", vim.log.levels.INFO)

