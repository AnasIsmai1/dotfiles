return {
  "nvimtools/none-ls.nvim",
  enabled = false,
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      debug = true,
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.completion.spell,
        -- null_ls.builtins.diagnostics.eslint_d,
        -- require("none-ls.diagnostics.eslint_d"),
        -- require("none-ls.diagnostics.eslint"),
      },
    })
    vim.keymap.set("n", "<leader>p", vim.lsp.buf.format, { desc = 'format file' })
  end,
}
