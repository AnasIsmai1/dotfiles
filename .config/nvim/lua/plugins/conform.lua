return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", 'BufNewFile' },
    config = function()
        local conform = require("conform")
        conform.setup({
            formatter_by_ft = {
                java = { "google-java-format" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                css = { "prettier" },
                go = { "gofumpt" },
                php = { "pretty-php" },
                scss = { "prettier" },
                html = { "prettier" },
                htmlangular = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                md = { "prettier" },
                sh = { "shfmt" },
                lua = { "stylua" },
                cpp = { "clang-format" },
                python = { "black", "isort" },
                sql = { "sqlfmt" },
            },
            format_after_save = {
                lsp_fallback = true,
                async = true,
                timeout_ms = 500,
            }
        })


        vim.keymap.set({ 'n', 'v' }, '<leader>p', function()
                conform.format({
                    lsp_fallback = true,
                    async = true,
                    timeout_ms = 500,
                })
            end,
            { desc = "Format File or Range in Visual Mode" })
    end
}
