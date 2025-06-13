vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            require("telescope.builtin").find_files()
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.ejs",
    command = "set filetype=html",
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(event)
        local bufnr = event.buf

        -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Common LSP keymaps
        local opts = { buffer = bufnr, noremap = true, silent = true }

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)                                    -- Go to definition
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)                                   -- Go to declaration
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)                                -- Go to implementation
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)                                    -- List references
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                                          -- Hover info
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)                             -- Signature help
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)                                -- Rename symbol
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)                  -- Code actions
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts) -- Format
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)                                  -- Previous diagnostic
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)                                  -- Next diagnostic
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)                          -- Show diagnostic
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)                          -- Diagnostics to loclist

        -- Optional: Format on save (uncomment to enable)
        -- vim.api.nvim_create_autocmd("BufWritePre", {
        --   buffer = bufnr,
        --   callback = function() vim.lsp.buf.format { async = false } end
        -- })

        -- Inlay hints, if supported
        if vim.lsp.inlay_hint then
            pcall(vim.lsp.inlay_hint.enable, bufnr, true)
        end

        -- Document highlight, if supported
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
            local hl_group = vim.api.nvim_create_augroup('LspDocumentHighlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                group = hl_group,
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                group = hl_group,
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
            })
        end
    end,
})
