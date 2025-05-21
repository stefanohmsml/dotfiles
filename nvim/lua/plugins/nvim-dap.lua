return {
  { "nvim-neotest/nvim-nio" },
  { "mfussenegger/nvim-dap" },
  { "carriga/nvim-dap-ui" },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb" },
      })
      -- Ensure VS Code JSON capabilities are available (nvim-dap uses this for some adapters)
      -- Setup nvim-dap-ui (optional, but highly recommended for a visual debugger interface)
      require("dapui").setup()

      -- Configure DAP for C++
      local dap = require("dap")

      -- Define the C++ debugger adapter (GDB or LLDB)
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        -- Option 1: For GDB
        command = "gdb",
        args = { "-q", "--interpreter=mi" },
        -- Option 2: For LLDB (uncomment and comment out GDB if you prefer LLDB)
        -- command = 'lldb-mi', -- lldb-mi provides the Machine Interface required by cppdbg
        -- args = {},
      }

      -- Function to dynamically get the executable path based on workspaceFolder
      local function get_current_project_executable()
        -- ${workspaceFolder} is automatically handled by nvim-dap if you open Neovim at the project root.
        -- Otherwise, you'd get the project root using vim.fs.find if needed.
        local project_root = vim.fn.expand("${workspaceFolder}")
        local project_name = vim.fn.fnamemodify(project_root, ":t") -- Gets the name of the root folder

        local executable_path = project_root .. "/build/" .. project_name

        -- Optional: Check if the file exists and is executable
        if not vim.fn.filereadable(executable_path) or not vim.fn.executable(executable_path) then
          vim.notify("Executable not found or not executable at: " .. executable_path, vim.log.levels.WARN)
          return nil
        end

        return executable_path
      end

      -- Define your debug configurations (this is your "launch.json" equivalent)
      dap.configurations.cpp = {
        {
          name = "Launch (GDB/LLDB) - Current Project",
          type = "cppdbg",
          request = "launch",
          -- 'program' can be a string or a function that returns a string.
          -- Using a function makes it dynamic based on the current workspace.
          program = function()
            return get_current_project_executable()
          end,
          cwd = "${workspaceFolder}", -- The debugger's working directory will be your project root
          stopOnEntry = true, -- Break at the beginning of main()
          -- GDB specific setup commands (enable pretty printing for STL containers, etc.)
          setupCommands = {
            {
              text = "-enable-pretty-printing",
              description = "enable pretty printing",
              ignoreFailures = true,
            },
            -- {
            --   text = "set sysroot /", -- Useful if GDB struggles with system libraries on some setups
            --   description = "Set sysroot",
            --   ignoreFailures = true
            -- },
          },
          -- No need for sourceFileMap here, as paths are consistent between debug info and host
          -- sourceFileMap = {},
        },
        -- You can add more configurations here if needed, e.g., for attaching to a process
        -- {
        --   name = "Attach to Process",
        --   type = "cppdbg",
        --   request = "attach",
        --   program = function() return get_current_project_executable() end, -- Optional: helps with symbols
        --   processId = function()
        --     return tonumber(vim.fn.input('Enter Process ID: '))
        --   end,
        --   cwd = "${workspaceFolder}",
        -- },
      }

      -- Keymaps (optional, but highly recommended for quick debugging)
      vim.keymap.set("n", "<F5>", function()
        require("dap").continue()
      end, { desc = "DAP: Continue/Start" })
      vim.keymap.set("n", "<F10>", function()
        require("dap").step_over()
      end, { desc = "DAP: Step Over" })
      vim.keymap.set("n", "<F11>", function()
        require("dap").step_into()
      end, { desc = "DAP: Step Into" })
      vim.keymap.set("n", "<F12>", function()
        require("dap").step_out()
      end, { desc = "DAP: Step Out" })
      vim.keymap.set("n", "<leader>b", function()
        require("dap").toggle_breakpoint()
      end, { desc = "DAP: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>br", function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, { desc = "DAP: Set Logpoint" })
      vim.keymap.set("n", "<leader>lp", function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Conditional breakpoint: "))
      end, { desc = "DAP: Set Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", function()
        require("dap").repl.toggle()
      end, { desc = "DAP: Toggle REPL" })
      vim.keymap.set("n", "<leader>dt", function()
        require("dapui").toggle()
      end, { desc = "DAP: Toggle UI" })
      vim.keymap.set("n", "<leader>dc", function()
        require("dap").run_config()
      end, { desc = "DAP: Run/Select Configuration" })
      vim.keymap.set("n", "<leader>dC", function()
        require("dap").clear_breakpoints()
      end, { desc = "DAP: Clear all breakpoints" })
      vim.keymap.set("n", "<leader>ds", function()
        require("dap").stop()
      end, { desc = "DAP: Stop Debugging" })
      vim.keymap.set("n", "<leader>dv", function()
        require("dap.ui.variables").hover()
      end, { desc = "DAP: Hover Variables" })
      vim.keymap.set("n", "<leader>dsv", function()
        require("dap.ui.variables").scopes()
      end, { desc = "DAP: Show Scopes" })
    end,
  },
}
