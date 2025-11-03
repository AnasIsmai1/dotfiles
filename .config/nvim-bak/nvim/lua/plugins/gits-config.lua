return {
    {
        "tpope/vim-fugitive",
        event = "BufReadPost",
        enabled = false,
    },
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPost",
        enabled = true,
        config = function()
            require("gitsigns").setup({
                -- signs = {
                --   add          = { text = '+' },
                --   change       = { text = '~' },
                --   delete       = { text = '_' },
                --   topdelete    = { text = '‾' },
                --   changedelete = { text = '~' },
                -- },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Only add mappings for valid Git files
                    if gs.status_dict then
                        map('n', ']c', gs.next_hunk)
                        map('n', '[c', gs.prev_hunk)
                    end
                end,
                debug_mode = true,
                attach_to_untracked = false, -- Disable attaching to untracked files
                current_line_blame = true,   -- Enable inline blame
            })
            vim.keymap.set("n", "<leader>g", "", { desc = "Git" })
            -- vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
            -- vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", {})
        end,
    },
    { 'akinsho/git-conflict.nvim', version = "*", config = true }
}
