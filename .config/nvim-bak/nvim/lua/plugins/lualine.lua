return {
    "nvim-lualine/lualine.nvim",
    event = "BufWinEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status")

        lualine.setup({
            options = {
                theme = "auto",
                disabled_filetypes = {
                    'alpha'
                },
            },
            sections = {
                lualine_b = {
                    "branch"
                },
                lualine_c = {
                    function()
                        return require('auto-session.lib').current_session_name(true)
                    end
                },
                lualine_x = {
                    "%S",
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        require("noice").api.statusline.mode.get,
                        cond = require("noice").api.statusline.mode.has,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        require("noice").api.status.command.get,
                        cond = require("noice").api.status.command.has,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        require("noice").api.status.search.get,
                        cond = require("noice").api.status.search.has,
                        color = { fg = "#ff9e64" },
                    },
                    -- { "mode" },
                    -- { "encoding" },
                    -- { "fileformat" },
                    { "filetype" },
                },
                lualine_y = {
                    {
                        'lsp_status',
                        icon = '', -- f013
                        symbols = {
                            spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
                            done = '✓',
                            separator = ' ',
                        },
                        ignore_lsp = {},
                    }
                }
            },
        })
    end,
}
