return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".git"
    },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly", -- or "workspace"
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",       -- "off", "basic", "strict"
                autoImportCompletions = true,
            }
        }
    },
    capabilities = {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = true,
                    documentationFormat = { "markdown", "plaintext" }
                }
            }
        }
    }
}
