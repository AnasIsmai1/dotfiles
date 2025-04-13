return {
    "folke/trouble.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "folke/todo-comments.nvim",
    },
    cmd = "Trouble",
    keys = {
        { "<leader>x",  "",                                    desc = "Trouble" },
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open/Toggle trouble list" },
        {
            "<leader>xd",
            "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
            desc = "Open trouble document diagnostics",
        },
        { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",  desc = "Open trouble location list" },
        { "<leader>xt", "<cmd>TodoToggle<CR>",              desc = "Open todos in trouble" },
    },
    config = function()
        require("trouble").setup({})
    end,
}
