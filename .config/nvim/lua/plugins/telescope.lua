return {
    {
        "nvim-telescope/telescope.nvim",
        -- event = "VimEnter",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-tree/nvim-web-devicons",
            "danielvolchek/tailiscope.nvim",
            "folke/todo-comments.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local action = require("telescope.actions")
            local builtin = require("telescope.builtin")

            require("telescope").setup({
                pickers = {
                    find_files = {
                        -- theme = "dropdown",
                    }
                },
                layout = {
                    vertical = {
                        width = 0.2,
                        height = 1.0,
                    }
                },
                prompt_prefix = "=> ",
                prompt_title = "anas",
                extensions = {
                    tailiscope = {
                        -- register to copy classes to on selection
                        register = "a",
                        -- indicates what picker opens when running Telescope tailiscope
                        -- can be any file inside of docs dir but most useful opts are
                        -- all, base, categories, classes
                        -- These are also accesible by running Telescope tailiscope <picker>
                        default = "base",
                        -- icon indicates an item which can be opened in tailwind docs
                        -- can be icon or false
                        doc_icon = "󰈙 ",
                        -- if you would prefer to copy with/without class selector
                        -- dot is maintained in display to differentiate class from other pickers
                        no_dot = true,
                        maps = {
                            i = {
                                back = "<C-h>",
                                open_doc = "<C-o>",
                            },
                            n = {
                                back = "b",
                                open_doc = "od",
                            },
                        },
                    },

                    defaults = {
                        layout_config = {
                            vertical = {
                                height = 0.4,
                            }
                        },
                        path_display = { "smart" },
                        mappings = {
                            i = {
                                ["<C-k>"] = action.move_selection_previous,
                                ["<C-j>"] = action.move_selection_next,
                                ["<C-q>"] = action.send_selected_to_qflist + action.open_qflist,
                            },
                            n = {
                                ['d'] = action.delete_buffer,
                                ['q'] = action.close,
                            }
                        },
                    },
                }
            })

            telescope.load_extension("fzf")
            telescope.load_extension("tailiscope")

            vim.keymap.set("n", "<leader>fw", "<cmd>Telescope tailiscope<cr>")

            vim.keymap.set("n", "<leader>f", "", { desc = "Telescope" })
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
            vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Open Recent Files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find Words in Files" })
            vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find String Under Cursor" })
            vim.keymap.set("n", "<leader>fb",
                "<cmd>Telescope buffers sort_mru=true sort_lastused=false initial_mode=normal<CR>",
                { desc = "Navigate in Between Buffers" })
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
