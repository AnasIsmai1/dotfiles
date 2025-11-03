return {
  {
    'ellisonleao/carbon-now.nvim',
    lazy = true,
    enabled = false,
    cmd = 'CarbonNow',
    opts = {}
  },
  {
    'mistricky/codesnap.nvim',
    lazy = "true",
    build = "make",
    keys = {
      { "<leader>ch", "<cmd>CodeSnap<cr>",     mode = { 'n', 'v' }, desc = "select to be saved to clipboard" },
      { "<leader>cs", "<cmd>CodeSnapSave<cr>", mode = { 'n', 'v' }, desc = "select to be saved to ~/Pictures/CodeSnaps/" }
    },
    config = function()
      require("codesnap").setup({
        save_path = "~/Pictures/CodeSnaps/",
        has_breadcrumbs = true,
        min_width = 700,
        bg_color = "#535c68",
        watermark = "",
        title = "Ismail",
      })
    end
  },
  -- {
  --   'michaelrommel/nvim-silicon',
  --   lazy = true,
  --   cmd = "Silicon",
  --   config = function()
  --     require("silicon").setup({
  --       font = "JetBrainsMono Nerd Font=34; Noto Color Emoji=34",
  --     })
  --   end
  -- }
}
