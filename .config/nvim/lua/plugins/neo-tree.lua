return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = { silent = true, noremap = true },
  keys = {
    {
      '<leader>e',
      '',
      opts,
      desc = "Explorer",
    },
    {
      '<leader>ee',
      '<cmd>Neotree filesystem toggle right<cr>',
      opts,
      desc = "Neotree Explorer Toggle",
    },
    {
      '<leader>eg',
      '<cmd>Neotree git_status toggle right<cr>',
      opts,
      desc = "Git Explorer",
    },
    {
      '<leader>eb',
      '<cmd>Neotree buffers toggle right<cr>',
      opts,
      desc = "Buffers Explorer",
    },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      sort_case_insensitive = true,
      auto_close = true,
      open_on_setup = false,
      hijack_cursor = true,
      update_cwd = true,
      git = {
        enable = true,
        ignore = true,
        timeout = 500,
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
      view = {
        width = 30,
        hide_root_folder = false,
        auto_resize = true,
      },
      window = {
        width = 40,
        mapping_options = {
          noremap = false,
          nowait = true,
        },
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
    })
    -- vim.keymap.set(
    --   "n",
    --   "<leader>ee",
    --   ":Neotree filesystem toggle right<CR>",
    --   { silent = true, desc = "Open Filesystem" }
    -- )
    -- vim.keymap.set("n", "<leader>ef", ":Neotree focus<CR>", { silent = true, desc = "Focus On File Explorer" })
    -- vim.keymap.set(
    --   "n",
    --   "<leader>eb",
    --   ":Neotree buffers right<CR>",
    --   { silent = true, desc = "Open All Existing Buffers" }
    -- )
    -- vim.keymap.set(
    --   "n",
    --   "<leader>eg",
    --   ":Neotree git_status right<CR>",
    --   { silent = true, desc = "Show The Git Status On All Files" }
    -- )
  end,
}
