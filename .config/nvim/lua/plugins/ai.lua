return {
    'Exafunction/codeium.nvim',
    enabled = false,
    event = { "InsertEnter", "BufReadPre" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("codeium").setup({})
    end
}
