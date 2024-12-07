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
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" }
        },
        dim_inactive = {
          enabled = true,    -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.25, -- percentage of the shade to apply to the inactive window
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      })
      vim.cmd.colorscheme "catppuccin-mocha"
    end,
  },
  -- {
  -- 	"AlexvZyl/nordic.nvim",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	config = function()
  -- 		require("nordic").load()
  -- 	end,
  -- 	},
  -- {
  --   "sho-87/kanagawa-paper.nvim",
  --   event = "vimenter",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  -- },
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
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  --   config = function()
  --     require("tokyonight").setup({
  --       style = "night",
  --       on_colors = function(colors)
  --         colors.bg_dark = "#011423"
  --       end,
  --     })
  --     vim.cmd("colorscheme tokyonight")
  --   end,
  -- },
}
