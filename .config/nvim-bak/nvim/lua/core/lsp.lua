---@diagnostic disable-next-line: undefined-global
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" }
}
capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }

-- Enable Lsp Servers
vim.lsp.enable({
    "gopls",
    "lua_ls",
    "pyright"
})

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        prefix = '●',
        severity = { min = vim.diagnostic.severity.HINT }
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
        focusable = false,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '✘',
            [vim.diagnostic.severity.WARN]  = '',
            [vim.diagnostic.severity.HINT]  = '',
            [vim.diagnostic.severity.INFO]  = '',
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN]  = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.HINT]  = 'DiagnosticSignHint',
            [vim.diagnostic.severity.INFO]  = 'DiagnosticSignInfo',
        },
        linehl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticLineError',
        }
    },
})

-- Hover window styling
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "rounded",
        max_width = 80,
    }
)

-- Signature help styling
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = "rounded",
        focusable = false,
        relative = "cursor",
    }
)
-- Show line diagnostics automatically in hover window
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
    end
})

-- Increase updatetime for better CursorHold experience
vim.opt.updatetime = 250
