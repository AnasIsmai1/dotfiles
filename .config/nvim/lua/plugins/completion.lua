return {
    'saghen/blink.cmp',
    dependencies = {
        "rafamadriz/friendly-snippets",
        "echasnovski/mini.icons",
    },
    version = '1.*',
    opts = {
        keymap = {
            preset = 'default',
            ['<CR>'] = { 'accept', 'fallback' },
            ['<C-K>'] = { 'show_documentation' },
            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<C-k>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
            ['<C-j>'] = { 'select_next', 'fallback' },
            ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
        },
        appearance = {
            nerd_font_variant = 'mono',
            window = {
                completion = {
                    border = "rounded",
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                },
                documentation = {
                    border = "rounded",
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                },
            },
        },
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500
            },
            menu = {
                auto_show = true,
                draw = {
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                                return kind_icon
                            end,
                            highlight = function(ctx)
                                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                                return hl
                            end,
                        },
                        kind = {
                            highlight = function(ctx)
                                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                                return hl
                            end,
                        },
                        menu = {
                            text = function(ctx)
                                if ctx.source == "lsp" then
                                    return "[LSP]"
                                elseif ctx.source == "snippets" then
                                    return "[Snip]"
                                elseif ctx.source == "buffer" then
                                    return "[Buf]"
                                elseif ctx.source == "path" then
                                    return "[Path]"
                                else
                                    return "[" .. ctx.source:sub(1, 1):upper() .. ctx.source:sub(2) .. "]"
                                end
                            end,
                            highlight = "CmpMenu",
                        }
                    }
                }
            },
            ghost_text = {
                enabled = true,
                show_with_menu = true,
                highlight = "CmpGhostText"
            },
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        cmdline = {
            enabled = true,
            keymap = { preset = 'cmdline' },
            sources = function()
                local type = vim.fn.getcmdtype()
                if type == '/' or type == '?' then return { 'buffer' } end
                if type == ':' or type == '@' then return { 'cmdline' } end
                return {}
            end,
            completion = {
                trigger = {
                    show_on_blocked_trigger_characters = {},
                    show_on_x_blocked_trigger_characters = {},
                },
                list = {
                    selection = {
                        preselect = true,
                        auto_insert = true,
                    },
                },
                menu = { auto_show = false },
                ghost_text = { enabled = true }
            }
        },
        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
        require('blink.cmp').setup(opts)
        -- Custom highlights for a modern look (adjust to theme)
        vim.api.nvim_set_hl(0, 'PmenuSel', { bg = '#313244', bold = true })
        vim.api.nvim_set_hl(0, 'CmpMenu', { fg = '#6c7086', italic = true })
        vim.api.nvim_set_hl(0, 'CmpGhostText', { fg = '#7f849c', italic = true })
    end

}
