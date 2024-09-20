return {
  "nvim-treesitter/nvim-treesitter",
  event = 'VeryLazy',
  config = function()
    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      auto_install = true,
      sync_install = true,
      indent = { enable = true },
      highlight = { enable = true },
      ensure_installed = {
        'lua',
        'json',
      }
    })
  end
}
