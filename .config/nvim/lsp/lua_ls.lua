return {
    cmd = {
        "lua-language-server"
    },
    filetypes = {
        "lua"
    },
    rootmarkers = {
        ".git",
        ".luacheckrc",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "selene.toml",
        "selene.yml",
        "stylua.toml"
    },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}
