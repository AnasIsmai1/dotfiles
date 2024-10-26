-- TODO: Make this work, currently does nothing.
return {
  'jghauser/fold-cycle.nvim',
  enabled = false,
  config = function()
    require("fold-cycle").setup({
      open_if_max_closed = true, -- closing a fully closed fold will open it
      close_if_max_opened = true,
      softwrap_movement_fix = true,
      -- keymaps
      vim.keymap.set('n', '<leader>do',
        function() return require('fold-cycle').open() end,
        { silent = true, desc = 'Fold-cycle: open folds' }),
      vim.keymap.set('n', '<leader>df',
        function() return require('fold-cycle').close() end,
        { silent = true, desc = 'Fold-cycle: close folds' }),
      vim.keymap.set('n', '<leader>dc',
        function() return require('fold-cycle').close_all() end,
        { remap = true, silent = true, desc = 'Fold-cycle: close all folds' })
    })
  end
}
