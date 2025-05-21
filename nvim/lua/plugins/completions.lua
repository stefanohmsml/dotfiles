return {
  {
    "L3MON4D3/LuaSnip",
    -- Load snippets ASAP, or on an event like "InsertEnter" or "VeryLazy"
    -- event = "InsertEnter",
    dependencies = {
      -- `cmp_luasnip` is a bridge between nvim-cmp and LuaSnip.
      -- It should be a dependency of nvim-cmp or LuaSnip.
      -- "saadparwaiz1/cmp_luasnip", -- We'll list this as nvim-cmp dependency

      -- `friendly-snippets` provides the actual snippet definitions.
      "rafamadriz/friendly-snippets",
    },
    config = function()
      -- You can configure LuaSnip further here if needed, e.g., custom paths
      -- require("luasnip").config.set_config({ ... })

      -- Load snippets from friendly-snippets and potentially other VSCode format snippet collections
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" }, -- Lazy load cmp until you enter insert or command mode
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- Source for LSP completions
      "saadparwaiz1/cmp_luasnip", -- Source for LuaSnip completions
      -- Other common sources you might consider:
      "hrsh7th/cmp-buffer", -- Source for buffer words (already used by name below)
      "hrsh7th/cmp-path", -- Source for file system paths
      -- "hrsh7th/cmp-cmdline", -- Source for command line
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip") -- For easier access

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- Expand snippets through LuaSnip
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
          ["<C-e>"] = cmp.mapping.abort(), -- Close completion menu
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection
          -- Additional useful mappings:
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }), -- i for insert mode, s for select mode (visual)
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          -- Group 1: Will be queried first or more broadly
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          -- Group 2: May be queried if Group 1 yields no results or after more characters are typed
          { name = "buffer" }, -- Completions from current buffer text
          { name = "path" }, -- Completions for file system paths (if cmp-path is added)
        }),
        -- Optional: Configure formatting for the completion menu items
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- Kind icons (requires a Nerd Font or similar)
            vim_item.kind =
              string.format("%s %s", require("lspkind").presets.default[vim_item.kind] or "", vim_item.kind)
            -- vim_item.kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item) -- Alternative with lspkind
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buff]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        -- Experimental features (optional)
        -- experimental = {
        --   ghost_text = true, -- Shows a preview of the completion inline
        -- },
      })

      -- If you're using cmp-cmdline, set it up for command mode
      -- cmp.setup.cmdline('/', {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = {
      --     { name = 'buffer' }
      --   }
      -- })
      -- cmp.setup.cmdline(':', {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = cmp.config.sources({
      --     { name = 'path' }
      --   }, {
      --     { name = 'cmdline' }
      --   })
      -- })
    end,
  },
  -- Optional: lspkind for nice icons in the completion menu
  {
    "onsails/lspkind.nvim",
    event = "VeryLazy", -- Load when cmp or LSP loads
  },
}
