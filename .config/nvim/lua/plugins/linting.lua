return {
  "mfussenegger/nvim-lint",
  event = {
    "BufReadPre",
    "BufNewFile",
    'InsertLeave',
  },

  config = function()
    local lint = require("lint")
    local eslint = lint.linters.eslint_d
    -- local pylint = lint.linters.pylint
    local cpplint = lint.linters.cpplint

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      sh = { "shellcheck" },
      -- scss = { "stylelint" },
      -- css = { "stylelint" },
      python = { "pylint" },
      cpp = { "cpplint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- pylint.cmd = "pylint" -- ensures pylint is installed
    -- pylint.stdin = false

    cpplint.args = {
      "-filter",
      '-legal/copyright',
    }

    eslint.args = {
      "--no-warn-ignored", -- <-- this is the key argument
      -- "--no-eslintrc",
      "--no-ignore",
      "--format",
      "json",
      "--stdin",
      "--stdin-filename",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    local lint_progress = function()
      local linters = require("lint").get_running()
      if #linters == 0 then
        return "󰦕"
      end
      return "󱉶 " .. table.concat(linters, ", ")
    end

    vim.keymap.set('n', '<leader>lg', lint_progress(), { desc = "Get All available running linters" })

    vim.keymap.set("n", "<leader>ll", function()
      lint.try_lint()
    end, { desc = "Lint file" })
  end,
}
