-- ================================ --
-- Autocompletado (nvim-cmp) + Autosuggest (ghost text)
-- ================================ --
local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
  local ok_luasnip2, luasnip2 = pcall(require, "luasnip")

  cmp.setup({
    completion = { completeopt = "menu,menuone,noselect" },

    -- Autosuggestion tipo "texto fantasma"
    experimental = { ghost_text = true },

    snippet = {
      expand = function(args)
        if ok_luasnip2 then
          luasnip2.lsp_expand(args.body)
        end
      end,
    },

    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"]     = cmp.mapping.abort(),
      ["<CR>"]      = cmp.mapping.confirm({ select = true }),

      -- Tab para navegar/completar + snippets
      ["<Tab>"]     = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif ok_luasnip2 and luasnip2.expand_or_jumpable() then
          luasnip2.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"]   = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif ok_luasnip2 and luasnip2.jumpable(-1) then
          luasnip2.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),

    -- Fuentes de sugerencias
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    }),
  })
else
  show_error("nvim-cmp no está instalado. Autocompletado deshabilitado.")
end
