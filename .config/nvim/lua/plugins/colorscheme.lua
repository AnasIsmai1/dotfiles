return {
  -- {
  -- 	"craftzdog/solarized-osaka.nvim",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	opts = function()
  --      return {
  --        transparent = true
  --      }
  -- 	end,
  -- },
  -- {
  -- 	"AlexvZyl/nordic.nvim",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	config = function()
  -- 		require("nordic").load()
  -- 	end,
  -- 	},
  {
    "sho-87/kanagawa-paper.nvim",
    event = "vimenter",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  -- {
  -- 	"tiagovla/tokyodark.nvim",
  -- 	opts = {
  -- 		-- custom options here
  -- 	},
  -- 	config = function(_, opts)
  -- 		require("tokyodark").setup(opts) -- calling setup is optional
  -- 		vim.cmd([[colorscheme tokyodark]])
  -- 	end,
  -- },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require("tokyonight").setup({
        style = "night",
        on_colors = function(colors)
          colors.bg_dark = "#011423"
        end,
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },
}
