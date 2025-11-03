return {
  'tamton-aquib/keys.nvim',
  enabled = false,
  config = function()
    local keys = require("keys")
    keys.setup({
      enable_on_startup = false,
      win_opts = {
        width = 20
      },
    })
    keys.current_keys(true)
    keys.toggle()
  end
}
