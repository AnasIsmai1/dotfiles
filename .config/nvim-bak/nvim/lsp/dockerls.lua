return {
    cmd = { "docker-langserver", "--stdio" },
    filetypes = { "dockerfile", "Dockerfile" },
    settings = {
        docker = {
            languageserver = {
                formatter = {
                    ignoreMultilineInstructions = false,
                },
                diagnostics = {
                    enabled = true,
                }
            }
        }
    },
    init_options = {
        provideFormatter = true,
    }
}
