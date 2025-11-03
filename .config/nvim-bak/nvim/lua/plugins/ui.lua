return {
    {
        "folke/noice.nvim",
        event = { "BufReadPre", "BufReadPost" },
        dependencies = {
            "rcarriga/nvim-notify",
        },
        config = function()
            local noice = require("noice")
            noice.setup({
                routes = {},
            })
        end,
        opts = function(_, opts)
            if not opts.routes then
                opts.routes = {}
            end

            if not opts.presets then
                opts.presets = {}
            end

            table.insert(opts.routes, 1, {
                filter = { event = "notify", find = "No Information available" },
                opts = {
                    skip = true,
                },
            })
            local focused = true
            vim.api.nvim_create_autocmd("FocusGained", {
                callback = function()
                    focused = true
                end,
            })
            vim.api.nvim_create_autocmd("FocusLost", {
                callback = function()
                    focused = false
                end,
            })
            table.insert(opts.routes, 1, {
                filter = {
                    cond = function()
                        return not focused
                    end,
                },
                view = "notify_send",
                opts = { stop = false },
            })

            opts.commands = {
                all = {
                    view = "split",
                    opts = { enter = true, format = "details" },
                    filter = {},
                },
            }
            opts.presets = {
                lsp_doc_border = true,        -- add a border to hover docs and signature help
                bottom_search = false,        -- use a classic bottom cmdline for search
                command_palette = false,      -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false,           -- enables an input dialog for inc-rename.nvim
            }
        end,
    },
    {
        "echasnovski/mini.animate",
        event = { "InsertEnter", "BufReadPre" },
        opts = function(_, opts)
            if not opts.scroll then
                opts.scroll = {}
            end

            opts.scroll = {
                enable = false,
            }
        end,
    },
    {
        "echasnovski/mini.icons",
        lazy = true,
        opts = {
            style = "glyph",
            file = {
                [".keep"] = { glyph = "󰊢 ", hl = "MiniIconsGrey" },
                ["devcontainer.json"] = { glyph = " ", hl = "MiniIconsAzure" },
            },
            filetype = {
                dotenv = { glyph = " ", hl = "MiniIconsYellow" },
            },
        },
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
        use_file_extension = function(ext, file) return true end,
    },
    {
        'NvChad/nvim-colorizer.lua',
        opts = {
            filetypes = { "*" },
            user_default_options = {
                mode = "background",
                tailwind = true,
            }
        }
    }
}
