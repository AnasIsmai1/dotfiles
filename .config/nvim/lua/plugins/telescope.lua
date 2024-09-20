return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
      "folke/todo-comments.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local action = require("telescope.actions")
      local builtin = require("telescope.builtin")

      require("telescope").setup({
        defaults = {
          path_display = { "smart" },
          mappings = {
            i = {
              ["<C-k>"] = action.move_selection_previous,
              ["<C-j>"] = action.move_selection_next,
              ["<C-q>"] = action.send_selected_to_qflist + action.open_qflist,
            },
          },
        },
      })

      telescope.load_extension("fzf")

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Open Recent Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find Words in Files" })
      vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find String Under Cursor" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Navigate in Between Buffers" })
      vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find todos" })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
