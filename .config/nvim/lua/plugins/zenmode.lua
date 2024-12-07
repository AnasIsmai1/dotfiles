return {
  'folke/zen-mode.nvim',
  enabled = false,
  config = function()
    require("zen-mode").setup({
      window = {
        width = 1
      },
      kitty = {
        enabled = true,
        font = "+8", -- font size increment
      },
    })
  end
}
