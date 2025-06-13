return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            local mason_tool_installer = require("mason-tool-installer")
            require("mason").setup()

            mason_tool_installer.setup({
                ensure_installed = {
                    -- Formatters/linters/etc.
                    "prettier",
                    "stylelint",
                    "stylua",
                    "eslint_d",
                    "isort",
                    "gofumpt",
                    "pylint",
                    "black",
                    -- LSP servers (Mason names)
                    "clangd", -- C/C++
                },
            })

            vim.keymap.set("n", "<leader>cm", ":Mason<CR>", { silent = true, desc = "Open Mason" })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ts_ls",     -- JavaScript/TypeScript
                    "angularls", -- Angular
                    "lua_ls",    -- Lua
                    "gopls",     -- Go
                    "clangd",    -- C/C++
                },
                automatic_installation = true,
            })
        end,
    },
}
