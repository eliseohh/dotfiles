-- Configuración de LSP para Lua
vim.lsp.config("lua_ls", {
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }

    -- Formateo manual con <leader>lf
    vim.keymap.set("n", "<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, opts)

    -- Autoformateo al guardar
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,

  capabilities = capabilities, -- si ya lo definiste en tu init
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
      format = { enable = true },
    },
  },
})
