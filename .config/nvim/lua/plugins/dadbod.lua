return {
  "kristijanhusak/vim-dadbod-ui",
  event = {"BufReadPre", "BufNewFile"},
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true},
    {'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql'}, lazy = true }
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function ()
      vim.g.db_ui_use_nerd_fonts = 1
  end,
  keys = {
    {
      '<leader>ed',
      '<cmd>Neotree close<cr><cmd>tabnew<cr><bar><bar><cmd>DBUI<cr>',
      desc='Open DB connection'
    }
  }
}
