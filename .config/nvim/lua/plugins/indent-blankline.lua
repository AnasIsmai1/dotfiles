return {
	"lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
	main = "ibl",
	--@module "ibl"
	--@type ibl.config
	opts = {},
  config = function()
    require("ibl").setup({})
  end
}
