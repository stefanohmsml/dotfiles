return {
  -- nvim-cmp: Autocompletion plugin
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- Load nvim-cmp when entering insert mode
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim", -- Optional
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind") -- Optional

      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = lspkind.cmp_format({ -- Optional: if using lspkind
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
          -- Basic formatting if not using lspkind
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },

        -- CRITICAL CHANGE FOR MANUAL TRIGGERING:
        -- Avoid cmp.mapping.preset.insert() if its defaults cause auto-triggering.
        -- Define all mappings explicitly.
        mapping = {
          -- Scroll documentation
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Abort completion
          ["<C-e>"] = cmp.mapping.abort(),

          -- Accept selection:
          -- By default, <CR> will confirm the selected item.
          -- Set `select` to `false` to only confirm if you've explicitly selected one with C-n/C-p.
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          -- Manual completion triggers
          ["<C-Space>"] = cmp.mapping.complete(), -- Standard manual trigger
          ["<D-Space>"] = cmp.mapping.complete(), -- For Cmd+Space on macOS

          -- Tab behavior:
          -- - If menu visible & item selected: confirm.
          -- - Else if snippet expandable: expand/jump.
          -- - Else: trigger completion.
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              cmp.complete() -- Manually trigger completion
            end
          end, { "i", "s" }),

          -- Shift+Tab behavior:
          -- - If menu visible: select previous.
          -- - Else if snippet jumpable backward: jump.
          -- - Else: fallback (e.g., de-indent).
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Navigation within the completion menu
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            else
              -- If you want C-n to also trigger completion if the menu isn't visible:
              -- cmp.complete()
              -- Else, let it do its default Neovim action (often moves cursor down)
              fallback()
            end
          end, { "i", "s" }),

          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            else
              -- If you want C-p to also trigger completion if the menu isn't visible:
              -- cmp.complete()
              -- Else, let it do its default Neovim action (often moves cursor up)
              fallback()
            end
          end, { "i", "s" }),
        },

        -- By not setting up `event` based completion triggers (like `InsertCharPre` or `TextChangedI`)
        -- to call `cmp.complete()`, and by explicitly defining mappings,
        -- the completion menu will only appear upon manual invocation.
      })

      -- Ensure LSP capabilities are set up correctly for nvim-cmp
      -- This is typically done in your lspconfig setup:
      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- require('lspconfig').your_lsp_server.setup {
      --   capabilities = capabilities,
      -- }
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "saadparwaiz1/cmp_luasnip" },
    config = function()
      -- local luasnip = require('luasnip')
      -- require('luasnip.loaders.from_vscode').lazy_load() -- Example
    end,
  },

  { -- Optional: lspkind.nvim for icons
    "onsails/lspkind.nvim",
    event = "BufReadPre",
  },
}
