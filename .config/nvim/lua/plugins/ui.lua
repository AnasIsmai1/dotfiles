return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-notify",
      "MunifTanjim/nui.nvim",
    },
    opts = function(_, opts)
      if not opts.routes then
        opts.routes = {}
      end

      if not opts.presets then
        opts.presets = {}
      end

      table.insert(opts.routes, 1, {
        filter = { event = "notify", find = "No Information available" },
        opts = {
          skip = true,
        },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      opts.commands = {
        all = {
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }
      opts.presets = {
        lsp_doc_border = true,        -- add a border to hover docs and signature help
        bottom_search = false,        -- use a classic bottom cmdline for search
        command_palette = false,      -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
      }
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      background_color = "#000000",
      -- render = "wrapped-compact",
      render = "default",
      stages = "slide",
    },
    -- vim.keymap.set('n', '<leader>dn', require("notify").dismiss(), { desc = "dismiss notifications" })
  },
  {
    "echasnovski/mini.animate",
    opts = function(_, opts)
      if not opts.scroll then
        opts.scroll = {}
      end

      opts.scroll = {
        enable = false,
      }
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢 ", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = " ", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = " ", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
