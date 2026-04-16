return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>fw",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Find Words (Live Grep)",
    },
    {
      "<leader>fW",
      function()
        require("telescope.builtin").grep_string()
      end,
      desc = "Find Word Under Cursor",
    },
  },
}
