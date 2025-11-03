return {
	"folke/todo-comments.nvim",
	events = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local todo_comments = require("todo-comments")

		local keymap = vim.keymap

		keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "Next Todo Comment" })

		keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "Previous Todo Comment" })

		todo_comments.setup({})
	end,
}
