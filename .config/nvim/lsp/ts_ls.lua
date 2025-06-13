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
        "javascriptreact",
        "javascript.jsx"
    },
    root_markers = {
        "package.json",
        "tsconfig.json",
        ".git"
    }, -- not always respected, see below
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
    }
}
