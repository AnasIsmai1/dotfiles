return {
    { -- tailwind-tools.lua
        "luckasRanarison/tailwind-tools.nvim",
        name = "tailwind-tools",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim", -- optional
        },
        opts = {
            document_color = {
                enabled = false,
            }
        },
        vim.keymap.set('n', '<leader>tt', '<cmd>TailwindConcealToggle<CR>',
            { desc = "Tailwind Conceal Toggle", silent = true })
    },
    {
        "MaximilianLloyd/tw-values.nvim",
        config = function()
            require('tw-values').setup({
                border = "rounded",          -- Valid window border style,
                show_unknown_classes = true, -- Shows the unknown classes popup
                focus_preview = true,        -- Sets the preview as the current window
                copy_register = "",          -- The register to copy values to,
                keymaps = {
                    copy = "<C-y>"           -- Normal mode keymap to copy the CSS values between {}
                }
            })
        end,
        vim.keymap.set('n', "<leader>tv", "<cmd>TWValues<cr>", { desc = "Show tailwind CSS values" })
    },
}
