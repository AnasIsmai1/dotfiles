return {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
                shadow = true,
                nilness = true,
                unusedwrite = true,
                fieldalignment = true,
            },
            codelenses = {
                gc_details = true,
                generate = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            matcher = "Fuzzy",
            diagnosticsDelay = "500ms",
            symbolMatcher = "FastFuzzy",
        }
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
    }
}
