return {
  'jghauser/fold-cycle.nvim',
  config = function()
    require("fold-cycle").setup({
      vim.keymap.set('n', '<leader>do',
        function() return require('fold-cycle').open() end,
        { silent = true, desc = 'Fold-cycle: open folds' }),
      vim.keymap.set('n', '<leader>df',
        function() return require('fold-cycle').close() end,
        { silent = true, desc = 'Fold-cycle: close folds' }),
      vim.keymap.set('n', '<leader>dc',
        function() return require('fold-cycle').close_all() end,
        { remap = true, silent = true, desc = 'Fold-cycle: close all folds' }) })
  end
}
