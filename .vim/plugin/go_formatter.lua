-- ========================================== --
--               GO FORMATTER                 --
--      Formatea y resalta errores en Go     --
-- ========================================== --

local api = vim.api

-- Función para verificar si un comando existe
local function is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Formateo de Go
local function go_format()
  local bufnr = api.nvim_get_current_buf()
  if vim.bo.filetype ~= "go" then return end

  if vim.fn.exists(":GoFmt") == 2 then
    vim.cmd("silent! GoFmt")
  elseif is_executable("gofmt") then
    local filename = api.nvim_buf_get_name(bufnr)
    vim.fn.jobstart("gofmt -w " .. vim.fn.shellescape(filename), {
      on_exit = function()
        if api.nvim_get_current_buf() == bufnr then
          vim.cmd("e!")
        end
      end,
    })
  else
    vim.notify("No se encontró 'gofmt' ni 'vim-go' para formatear Go", vim.log.levels.WARN)
  end
end

-- Mostrar errores en columna y minibuffer
local function show_diagnostics()
  -- Activar signos
  vim.diagnostic.config({
    virtual_text = {
      prefix = '●', -- símbolo para mensajes inline
      spacing = 2,
      severity = vim.diagnostic.severity.ERROR,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
end

-- Configuración automática
api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    go_format()
  end,
})

api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.go",
  callback = show_diagnostics,
})

-- Keymap opcional para formateo manual
vim.keymap.set("n", "<leader>gf", go_format, { desc = "Formatear archivo Go" })

-- Mensaje
vim.notify("Go Formatter cargado: formateo y diagnostics activados", vim.log.levels.INFO)
