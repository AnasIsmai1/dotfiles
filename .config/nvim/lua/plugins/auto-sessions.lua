return {
  "rmagatti/auto-session",
  lazy = false,
  config = function ()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore_enabled = false,
      auto_session_suppress_dirs = { "~/", "~/Desktop", "~/Downloads", "~/Documents"}
    })

    local keymap = vim.keymap

    keymap.set('n', '<leader>wr', '<cmd>SessionRestore<CR>', { desc = "Restore Session for CWD"})
    keymap.set('n', '<leader>ws', '<cmd>SessionSave<CR>', { desc = "Save session for auto session root dir"})
    keymap.set('n', '<leader>wp', '<cmd>SessionSearch<CR>', { desc = "Search in Saved Session"})
    keymap.set('n', '<leader>wa', '<cmd>SessionToggleAutoSave<CR>', { desc = "Toggle Autosave"})

  end
}
