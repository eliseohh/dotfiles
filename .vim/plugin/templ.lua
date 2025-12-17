-- ========================================== --
--               INIT.LUA                     --
--        Configuración completa Templ       --
--        Neovim 0.11+ + Mason + Snippets    --
-- ========================================== --

-- ================================ --
-- Función para verificar binarios
-- ================================ --
local function is_executable(cmd)
    return vim.fn.executable(cmd) == 1
end

-- ================================ --
-- Formateo custom para *.templ
-- ================================ --
local custom_format = function()
    if vim.bo.filetype == "templ" then
        local bufnr = vim.api.nvim_get_current_buf()
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local cmd = "templ fmt " .. vim.fn.shellescape(filename)
        if is_executable("templ") then
            vim.fn.jobstart(cmd, {
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
        vim.lsp.buf.format()
    end
end

-- ================================ --
-- Función on_attach para LSP
-- ================================ --
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
    -- Keymap para formateo manual
    vim.keymap.set("n", "<leader>lf", custom_format, opts)
end

-- ================================ --
-- Setup Mason y Mason-LSPConfig
-- ================================ --
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "gopls",
        "ts_ls",
        "html",
        "tailwindcss",
    },
    automatic_installation = true,
})

-- ================================ --
-- Configuración común para LSPs
-- ================================ --
local common_config = {
    on_attach = on_attach,
    capabilities = capabilities, -- definido por nvim-cmp u otro plugin
}

-- ================================ --
-- TailwindCSS configuración
-- ================================ --
local tailwind_config = vim.tbl_extend("force", common_config, {
    filetypes = { "templ", "astro", "javascript", "typescript", "react" },
    settings = {
        tailwindCSS = {
            includeLanguages = {
                templ = "html",
            },
        },
    },
})
vim.lsp.config("tailwindcss", tailwind_config)

-- ================================ --
-- HTML configuración con templ y htmx
-- ================================ --
vim.lsp.config("html", vim.tbl_extend("force", common_config, {
    filetypes = { "html", "templ", "htmx" },
}))

-- ================================ --
-- Servidores Mason-LSPConfig
-- ================================ --
local mason_servers = {
    "gopls",
    "tsserver",
    "html",
    "tailwindcss",
}
for _, server in ipairs(mason_servers) do
    if server == "html" then
        vim.lsp.config(server, vim.tbl_extend("force", common_config, {
            filetypes = { "html", "templ", "htmx" }
        }))
    else
        vim.lsp.config(server, common_config)
    end
end

-- ================================ --
-- Servidores manuales
-- ================================ --
local manual_servers = {
    { name = "ccls", cmd = "ccls" }, 
    { name = "cmake", cmd = "cmake-language-server" },
}
for _, server in ipairs(manual_servers) do
    if is_executable(server.cmd) then
        vim.lsp.config(server.name, common_config)
    else
        vim.notify("No se encontró LSP " .. server.name .. " (" .. server.cmd .. ")", vim.log.levels.WARN)
    end
end

-- ================================ --
-- Habilitar todos los servidores
-- ================================ --
local all_servers = vim.tbl_map(function(s) return s.name or s end, vim.list_extend(mason_servers, manual_servers))
vim.lsp.enable(all_servers)

-- ================================ --
-- Autocmd para formateo *.templ antes de guardar
-- ================================ --
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.templ" },
    callback = custom_format
})

-- ================================ --
-- Snippets para Templ y HTMX
-- ================================ --
-- Usando LuaSnip: coloca tus snippets en ./snippets/templ y ./snippets/htmx
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load({
    paths = { "./snippets" },
})

-- Ejemplos de snippets inline
luasnip.add_snippets("templ", {
    luasnip.snippet("if", {
        luasnip.text_node("{% if "),
        luasnip.insert_node(1, "condition"),
        luasnip.text_node(" %}"),
        luasnip.insert_node(2, ""),
        luasnip.text_node("{% endif %}"),
    }),
})
luasnip.add_snippets("htmx", {
    luasnip.snippet("hx-get", {
        luasnip.text_node('hx-get="'),
        luasnip.insert_node(1, "/url"),
        luasnip.text_node('" hx-target="'),
        luasnip.insert_node(2, "#target"),
        luasnip.text_node('"'),
    }),
})

-- ================================ --
-- Mensaje final de confirmación
-- ================================ --
vim.notify("Neovim listo para Templ, HTMX y TailwindCSS!", vim.log.levels.INFO)

