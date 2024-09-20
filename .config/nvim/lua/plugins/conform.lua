return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", 'BufNewFile'},
  config = function ()
    local conform = require("conform")
    conform.setup({
      formatter_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        htmlangular = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        md = { "prettier" },
        lua = { "stylua" },
        cpp = { "clang-format" },
        python = { "black", "isort" },
      },
      format_on_save = {
        lsp_fallback = true,
        async = true,
        timeout_ms = 500,
      }
    })


    vim.keymap.set({ 'n', 'v' }, '<leader>p', function ()
      conform.format({
        lsp_fallback = true,
        async = true,
        timeout_ms = 500,
      })
     end ,
    { desc = "Format File or Range in Visual Mode" })
  end
}
