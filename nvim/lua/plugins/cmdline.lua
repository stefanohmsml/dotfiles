return {
  'VonHeikemen/fine-cmdline.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim'
  },
  config = function()
    local fineline = require('fine-cmdline')

    fineline.setup({
      cmdline = {
        -- Prompt can influence the completion engine.
        -- Change it to something that works for you
        prompt = ':',

        -- Let the user handle the keybindings
        enable_keymaps = true
      },
      popup = {
        buf_options = {
          -- Setup a special file type if you need to
          filetype = 'FineCmdlinePrompt'
        }
        },
    })
     -- Add your custom keymap to trigger fine-cmdline
    vim.keymap.set('n', ':', function()
      fineline.open()
    end, { noremap = true, silent = true, desc = "Open Fine Cmdline" })

    vim.keymap.set('v', ':', function()
      fineline.open()
    end, { noremap = true, silent = true, desc = "Open Fine Cmdline" })
  end
}
