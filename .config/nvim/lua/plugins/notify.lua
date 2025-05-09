return {
    "rcarriga/nvim-notify",
    enabled = false,
    cmd = "Notifications",
    keys = {
        {
            "<leader>un",
            function()
                require("notify").dismiss({ silent = true, pending = true })
            end,
            desc = "Dismiss All Notifications",
        },
    },
    opts = {
        stages = "static",
        render = "wrapped-compact",
        background_color = "#000000",
        timeout = 5000,
        max_height = function()
            return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
            return math.floor(vim.o.columns * 0.75)
        end,
        on_open = function(win)
            vim.api.nvim_win_set_config(win, { zindex = 100 })
        end,
    },
}
