return {
    'stevearc/oil.nvim',
    opts = {},
    config = function()
        local oil = require("oil")
        oil.setup({
            columns = {
                "icons",
            },
            view_options = {
                show_hidden = true
            }
        })
        vim.keymap.set('n', '-', oil.open, { desc = "Open parent directory" })
    end
}
