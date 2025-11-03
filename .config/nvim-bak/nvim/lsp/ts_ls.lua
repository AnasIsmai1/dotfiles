local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }

return {
    cmd = {
        "typescript-language-server",
        "--stdio"
    },
    filetypes = {
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "javascript",
        "javascript.js",
        "javascriptreact",
        "javascript.jsx"
    },
    root_markers = {
        "package.json",
        "tsconfig.json",
        ".git"
    },
    settings = {
        typescript = {
            format = { enable = false },
            preferences = {
                importModuleSpecifierPreference = "relative",
                quoteStyle = "auto",
            },
            inlayHints = { includeInlayParameterNameHints = "all" }
        },
        javascript = {
            format = { enable = false },
            preferences = {
                importModuleSpecifierPreference = "relative",
                quoteStyle = "auto",
            },
            inlayHints = { includeInlayParameterNameHints = "all" }
        },
        completions = {
            completeFunctionCalls = true,
        },
    },
    init_options = {
        hostInfo = "neovim"
    },
    capabilities = capabilities,
}
