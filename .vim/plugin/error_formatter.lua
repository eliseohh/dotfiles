-- ========================================== --
--           ERROR & FORMATO LSP              --
--      Muestra errores y formatea al guardar --
-- ========================================== --

local M = {}

-- ================================ --
-- Configuración de diagnósticos
-- ================================ --
vim.diagnostic.config({
  virtual_text = {
    prefix = "",
    spacing = 2,
    format = function(d)
      return string.format("%s", d.message)
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Estilos de colores y cursiva
vim.cmd([[highlight DiagnosticVirtualTextError guifg=#FF5555 gui=italic]])
vim.cmd([[highlight DiagnosticVirtualTextWarn guifg=#F1FA8C gui=italic]])
vim.cmd([[highlight DiagnosticVirtualTextInfo guifg=#8BE9FD gui=italic]])
vim.cmd([[highlight DiagnosticVirtualTextHint guifg=#50FA7B gui=italic]])

-- Signos de la columna
local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- ================================ --
-- Mostrar float al pasar el cursor
-- ================================ --
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false, border = "rounded" })
  end,
})

-- ================================ --
-- Formateo al guardar para todos los buffers con LSP activo
-- ================================ --
M.setup_format_on_save = function()
  vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.lsp.buf.format then
        vim.lsp.buf.format({ bufnr = bufnr })
      end
    end,
  })
end

return M
