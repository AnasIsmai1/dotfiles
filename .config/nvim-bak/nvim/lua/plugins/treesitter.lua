return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter").setup({
				auto_install = true,
				sync_install = false,
				indent = { enable = true },
				highlight = { enable = true },
				ensure_installed = {
					"lua",
					"json",
					"markdown",
					"markdown_inline",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>ss",
						node_incremental = "<leader>si",
						scope_incremental = "<leader>sc",
						node_decremental = "<leader>sd",
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
						["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
						["al"] = { query = "@loop.outer", desc = "Select outer part of a loop region" },
						["il"] = { query = "@loop.inner", desc = "Select inner part of a loop region" },
					},
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<c-v>",
					},
					include_surrounding_whitespace = true,
				},
			})
		end,
	},
}
