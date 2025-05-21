return {
  {
    "williamboman/mason.nvim",
    lazy = false, -- Fine for a foundational plugin
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    -- For slightly better startup, consider `event = "VeryLazy"` or `ft = { "typescriptreact", ... }`
    -- lazy = false is okay if you prefer it to load early.
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" }, -- Explicit dependencies
    ensure_installed = {
      "clangd",
      "typescript-language-server", -- Crucial for React (TSX/JSX)
      "eslint-lsp", -- Highly recommended for React (linting & formatting via ESLint)
      "tailwindcss-language-server", -- If you use Tailwind CSS
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- More specific lazy loading
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      -- React / JavaScript / TypeScript
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        -- Optional: add specific settings for tsserver if needed
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        -- root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
      })

      -- ESLint for advanced linting and formatting (works well with tsserver)
      lspconfig.eslint.setup({ -- Renamed from eslint_d to eslint (eslint-lsp package name)
        capabilities = capabilities,
        -- Optional: settings like on_attach for formatting on save
        -- on_attach = function(client, bufnr)
        --   if client.supports_method("textDocument/formatting") then
        --     vim.api.nvim_create_autocmd("BufWritePre", {
        --       group = vim.api.nvim_create_augroup("LspFormat_" .. bufnr, { clear = true }),
        --       buffer = bufnr,
        --       command = "FormatWrite", -- Requires a custom FormatWrite command or use a formatting plugin
        --     })
        --   end
        -- end,
      })

      -- HTML (often covered by tsserver for JSX, but can be separate)
      lspconfig.html.setup({
        capabilities = capabilities,
      })

      -- Lua
      -- Neovim 0.11.x has better built-in support for configuring lua_ls.
      -- You can often simplify this or rely on nvim-lspconfig's defaults.
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false, -- Avoids issues with non-workspace files
            },
            telemetry = { enable = false },
            diagnostics = {
              globals = { "vim" }, -- Add other globals your Lua code uses
            },
          },
        },
      })

      -- Clangd (C/C++)
      -- Your custom setup for clangd is good if you need these specific options.
      -- `mason-lspconfig` would have provided a default setup if `clangd` is in `ensure_installed`.
      -- This explicit setup will take precedence.
      lspconfig.clangd.setup({
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
        capabilities = capabilities, -- You already defined capabilities above
      })

      -- TailwindCSS (if you added it to ensure_installed)
      if vim.tbl_contains(require("mason-lspconfig").get_installed_servers(), "tailwindcss-language-server") then
        lspconfig.tailwindcss.setup({
          capabilities = capabilities,
        })
      end

      -- General LSP keymaps (example) - place this inside the config function
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
          -- Add more mappings as needed
        end,
      })
    end,
  },
}
