return {
    {
        'MeanderingProgrammer/markdown.nvim',
        enabled = true,
        main = 'render-markdown',
        opts = {},
        name = 'render-markdown', -- only needed if you have another plugin named markdown.nvim
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons'
        },
    },
}
