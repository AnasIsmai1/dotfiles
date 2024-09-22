return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim"
    },
    config = function()
      local mason_tool_installer = require("mason-tool-installer")

      require("mason").setup()

      mason_tool_installer.setup({
        ensure_installed = {
          "prettier",
          "stylelint",
          "stylua",
          "eslint_d",
          "isort",
          "pylint",
          "black",
        }
      })

      vim.keymap.set("n", "<leader>cm", ":Mason<CR>", { silent = true })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "angularls", "lua_ls", "eslint_d" },
        automatic_installation = true,
      })
    end,
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- Required LSP and Autocompletion Support
      { "neovim/nvim-lspconfig" },             -- LSP Config
      { "williamboman/mason.nvim" },           -- Mason
      { "williamboman/mason-lspconfig.nvim" }, -- Mason-LSP integration
      { "hrsh7th/nvim-cmp" },                  -- Autocompletion
      { "hrsh7th/cmp-nvim-lsp" },              -- LSP source for nvim-cmp
      { "L3MON4D3/LuaSnip" },                  -- Snippet engine
    },
    config = function()
      local lsp = require("lsp-zero")

      -- Use the recommended preset for simplicity
      lsp.preset("recommended")

      -- Ensure that these language servers are installed
      lsp.ensure_installed({
        "ts_ls",
        "eslint",
        "angularls",
        "cssls",
        "html",
        "emmet_ls",
        "lua_ls",
      })

      vim.diagnostic.config({
        virtual_text = {
          prefix = function(diagnostic)
            -- You can customize icons for different severity levels
            local icons = {
              [vim.diagnostic.severity.ERROR] = '✘',
              [vim.diagnostic.severity.WARN]  = ' ',
              [vim.diagnostic.severity.HINT]  = ' ',
              [vim.diagnostic.severity.INFO]  = ' ',
            }
            return icons[diagnostic.severity] or ''
          end,
          spacing = 4,            -- Adjust spacing between the icon and the message
        },
        signs = true,             -- Show signs in the sign column
        update_in_insert = false, -- Update diagnostics in insert mode
        underline = true,         -- Underline the line with an error
        severity_sort = true,     -- Sort diagnostics by severity
      })

      -- Custom keybindings for LSP
      lsp.on_attach(function(_, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
        vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
        vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,
          { desc = "code action", buffer = bufnr, remap = true })
        vim.keymap.set("n", "<leader>sn", vim.lsp.buf.rename, opts)
      end)


      local function organize_imports()
        local params = {
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
        }
        vim.lsp.execute_command(params)
      end

      vim.api.nvim_create_user_command('OrganizeImports', organize_imports, {})

      vim.api.nvim_set_keymap('n', '<leader>o', ':OrganizeImports<CR>',
        { noremap = true, silent = true, desc = "Organize Imports within TS files" })

      -- Define icons for LSP diagnostics
      local signs = { Error = "✘", Warn = " ", Hint = " ", Info = " " }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Finalize the LSP setup
      lsp.setup({})

      -- -- Additional LSP configurations (optional)
      -- local lspconfig = require("lspconfig")
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      --
      -- -- TypeScript specific configurations (with organize imports command)
      -- local function organize_imports()
      --   local params = {
      --     command = "_typescript.organizeImports",
      --     arguments = { vim.api.nvim_buf_get_name(0) },
      --   }
      --   vim.lsp.buf.execute_command(params)
      -- end
      --
      -- lspconfig.ts_ls.setup({
      --   capabilities = capabilities,
      --   flags = { debounce_text_changes = 150 },
      --   root_dir = function(fname)
      --     return lspconfig.util.root_pattern("angular.json", "tsconfig.json", "package.json", ".git")(fname)
      --       or lspconfig.util.find_git_ancestor(fname)
      --   end,
      --   commands = {
      --     OrganizeImports = {
      --       organize_imports,
      --       description = "Organize Imports",
      --     },
      --   },
      -- })
      --
      -- -- CSS LSP setup
      -- lspconfig.cssls.setup({
      --   capabilities = capabilities,
      -- })
      --
      -- -- HTML LSP setup
      -- lspconfig.html.setup({
      --   capabilities = capabilities,
      -- })
      --
      -- -- Emmet LSP setup
      -- lspconfig.emmet_ls.setup({
      --   capabilities = capabilities,
      --   filetypes = { "html", "css", "javascript", "typescriptreact", "javascriptreact", "less", "sass", "scss" },
      -- })
      --
      -- -- Lua LSP setup
      -- lspconfig.lua_ls.setup({
      --   capabilities = capabilities,
      -- })
      --
      -- -- Angular LSP setup
      -- lspconfig.angularls.setup({
      --   capabilities = capabilities,
      -- })
    end,
  },
}
