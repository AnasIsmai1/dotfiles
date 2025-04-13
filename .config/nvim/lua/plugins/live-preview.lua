return {
  'brianhuster/live-preview.nvim',
  enabled = true,
  event = {
    "InsertEnter", "BufReadPre"
  },
  -- dependencies = { 'brianhuster/autosave.nvim' }, -- Not required, but recomended for autosaving
  config = function()
    require("live-preview").setup({

      cmd = "LivePreview",  -- Main command of live-preview.nvim
      port = 5500,          -- Port to run the live preview server on.
      autokill = true,      -- If true, the plugin will autokill other processes running on the same port (except for Neovim) when starting the server.
      browser = 'default',  -- ~/.co- Terminal command to open the browser for live-previewing (eg. 'firefox', 'flatpak run com.vivaldi.Vivaldi'). By default, it will use the default browser.
      dynamic_root = false, -- If true, the plugin will set the root directory to the previewed file's directory. If false, the root directory will be the current working directory (`:lua print(vim.uv.cwd())`).
      sync_scroll = true,   -- If true, the plugin will sync the scrolling in the browser as you scroll in the Markdown files in Neovim.
      picker = 'telescope', -- Picker to use for opening files. 3 choices are available: 'telescope', 'fzf-lua', 'mini.pick'. If nil, the plugin look for the first available picker when you call the `pick` command.

    })
  end,

  vim.keymap.set('n', '<leader>lp', '<cmd>LivePreview start<CR>', { desc = "LivePreview start" }),
  vim.keymap.set('n', '<leader>lc', '<cmd>LivePreview close<CR>', { desc = "LivePreview close" })
}
