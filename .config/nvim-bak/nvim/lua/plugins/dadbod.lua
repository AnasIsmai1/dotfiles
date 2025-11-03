return {
    {
        'tpope/vim-dadbod',
        dependencies = {
            'kristijanhusak/vim-dadbod-ui',
        },
        config = function()
            -- Set up your MySQL connections
            vim.g.dbs = {
                mysql_local = 'mysql://username:password@localhost:3306/database_name'
            }

            -- Basic DBUI configuration
            vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"
            vim.g.db_ui_use_nerd_fonts = 1

            -- Set up key mappings (optional)
            vim.keymap.set('n', '<leader>db', ':DBUIToggle<CR>', { noremap = true, silent = true })
        end,
        lazy = false,
    }
}
