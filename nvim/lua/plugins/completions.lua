return {
  -- nvim-cmp: Autocompletion plugin
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- Load nvim-cmp when entering insert mode
    dependencies = {
      -- Source for LSP completions
      "hrsh7th/cmp-nvim-lsp",
      -- Source for buffer word completions
      "hrsh7th/cmp-buffer",
      -- Source for file system path completions
      "hrsh7th/cmp-path",
      -- Snippet engine
      "L3MON4D3/LuaSnip",
      -- Source for LuaSnip completions
      "saadparwaiz1/cmp_luasnip",
      -- Optional: for nice icons (ensure you have a Nerd Font)
      -- 'onsails/lspkind.nvim',
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Optional: If you use lspkind.nvim for icons
      -- local lspkind = require('lspkind')

      -- Set completeopt for a better experience
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
          -- Optional: If you use lspkind.nvim for icons
          -- format = lspkind.cmp_format({
          --   mode = 'symbol_text', -- Show symbol and text
          --   maxwidth = 50,      -- Truncate overly long text
          --   ellipsis_char = '...', -- Character to use for truncation
          --   -- Default icons for different completion kinds
          --   -- You can customize these further
          --   before = function (entry, vim_item)
          --     return vim_item
          --   end
          -- })
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
        mapping = {
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              -- If completion is not visible and no snippet to jump, trigger completion.
              cmp.complete()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<D-Space>"] = cmp.mapping.complete(), -- Cmd+Space to trigger completion
          ["<C-Space>"] = cmp.mapping.complete(), -- Ctrl+Space as an alternative

          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        -- No automatic triggering on typing.
        -- We achieve this by not setting up event-based triggers like 'InsertCharPre'
        -- to call cmp.complete() automatically.
      })

      -- Setup nvim-cmp capabilities for LSP servers
      -- This should ideally be done where you configure your LSP servers
      -- For example, in your lspconfig.lua or similar:
      --
      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- require('lspconfig').your_lsp_server.setup {
      --   capabilities = capabilities,
      --   -- other lsp settings
      -- }
      --
      -- If you want to set it globally here (though less common for lazy.nvim structure):
      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- For each server in lspconfig, you'd typically pass these capabilities.
      -- As a fallback, some people might iterate over all servers, but it's better
      -- to set it per server setup.
      -- Example:
      -- local lspconfig = require('lspconfig')
      -- for _, server_name in ipairs(lspconfig.util.available_servers()) do
      --    lspconfig[server_name].setup({
      --        capabilities = capabilities
      --    })
      -- end
      -- NOTE: The above loop is a generic example and might need adjustments
      -- based on your specific LSP configuration setup. It's generally better
      -- to pass capabilities directly when setting up each LSP server individually.
    end,
  },

  -- LuaSnip: Snippet engine
  {
    "L3MON4D3/LuaSnip",
    -- event = "InsertEnter", -- Load when entering insert mode
    -- Or, if you prefer to load it with nvim-cmp:
    dependencies = { "saadparwaiz1/cmp_luasnip" }, -- Ensure cmp_luasnip is also loaded
    config = function()
      local luasnip = require("luasnip")
      -- You can configure LuaSnip further here if needed
      -- e.g., require('luasnip.loaders.from_vscode').lazy_load() to load VSCode style snippets
      -- luasnip.filetype_extend("javascript", { "html" }) -- example filetype extension
    end,
  },

  -- Optional: lspkind.nvim for icons in completion menu
  {
    "onsails/lspkind.nvim",
    event = "BufReadPre", -- Load early to make icons available
  },
}
