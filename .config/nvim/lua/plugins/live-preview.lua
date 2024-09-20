return {
  'brianhuster/live-preview.nvim',
  event = {
    "InsertEnter", "BufReadPre"
  },
  dependencies = { 'brianhuster/autosave.nvim' }, -- Not required, but recomended for autosaving
  config = function ()
    require("live-preview").setup({})
  end
}
