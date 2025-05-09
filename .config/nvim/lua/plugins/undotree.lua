return {
  "jiaoshijie/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    local undotree = require("undotree")

    undotree.setup({})
  end,
  keys = { -- load the plugin only when using it's keybinding:
    { "<leader>ut", "<cmd>lua require('undotree').toggle()<cr>", desc = "Open Undotree" },
  },
}
