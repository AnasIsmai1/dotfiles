return {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
        require("dressing").setup({
            select = {
                enabled = false,
                backend = { "nui", "telescope", "fzf" }, -- choose which backend to use for select
                nui = {
                    position = "50%",                    -- position for Nui-based selections
                    -- size = 30,                           -- size of the selection window
                },
                fzf = {
                    fuzzy = true, -- enables fuzzy searching in fzf
                },
            },
            input = {
                relative = "editor", -- make the input box relative to the editor window
                border = "rounded",  -- style of the input box
                min_width = 30,      -- minimum width of the input box
            },
        })
    end,
}
