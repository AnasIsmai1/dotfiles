return {
    cmd = {
        "ngserver",
        "--stdio",
        "--tsrobeLocations",
        "../..,?/node_modules",
        "--ngrobeLocations",
        "../../@angular/language-server/node_modules,?/node_modules/@angular/language-server/node_modules",
        "--angularCoreVersion"
    },
    filetypes =
    {
        "typescript",
        "html",
        "typescript.tsx",
        "htmlangular"
    },
    root_markers = {
        "angular.json",
        "nx.json"
    },
    settings = {
        angular = {
            validate = true, -- default is true

            strictTemplates = true,

            suggest = {
                angularLibraries = true,
                htmlSnippets = true,
            },

            fileExtensions = { ".ts", ".html" },
        }
    },

    init_options = {
        embeddedLanguages = {
            html = true,
            css = true,
            scss = true,
            less = true,
        },
        configuration = {
            suggest = {
                angularLibraries = true,
                htmlSnippets = true,
            },
            pipeCompletion = true,
            directiveCompletion = true,
        },
        hostInfo = "neovim",
    }
}
