return {
    {
        "hrsh7th/nvim-cmp",
        event = { "InsertEnter" },
        dependencies = {
            -- "tailwind-tools",       -- for tailwind color highlight
            -- "onsails/lspkind-nvim", -- for enhanced completion icons
            "roobert/tailwindcss-colorizer-cmp.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local cmp = require("cmp")
            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node
            local f = ls.function_node
            local fmt = require("luasnip.extras.fmt").fmt

            ls.add_snippets("lua", {
                s("fn", fmt("local function {}({})\n  {}\nend", { i(1, "name"), i(2, "args"), i(0, "body") })),
            }, {
                key = "lua_snippets",
            })

            ls.add_snippets("all", {
                s("greet", {
                    t("Hello, "), i(1, "name"), t("! Welcome to Neovim."), i(2, "message"),
                }),
            })

            ls.add_snippets("cpp", {
                s("bp", {
                    t({
                        "",
                        "#include <iostream>",
                        "",
                        "using namespace std;",
                        "",
                        "int main() {",
                        "    cout << \"Hello, World!\" <<  endl;",
                        "    return 0;",
                        "}"
                    }), }),
            })

            -- Load snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Setup for cmdline completions
            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man', '!' }
                        }
                    }
                })
            })

            vim.keymap.set({ "i", "s" }, "<C-j>", function()
                if ls.expand_or_jumpable() then
                    ls.expand_or_jump()
                end
            end, { silent = true })

            vim.keymap.set({ "i", "s" }, "<C-k>", function()
                if ls.jumpable(-1) then
                    ls.jump(-1)
                end
            end, { silent = true })

            vim.keymap.set("i", "<C-l>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, { silent = true })

            -- Setup for insert mode completions
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                formatting = {
                    -- format =
                    --     lspkind.cmp_format({
                    --         with_text = true, -- Show text with icons
                    --         maxwidth = 50,    -- Adjust max width of completion item
                    --         menu = {
                    --             nvim_lsp = "[LSP]",
                    --             luasnip = "[Snip]",
                    --             path = "[Path]",
                    --             buffer = "[Buffer]",
                    --         },
                    --     }),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                    { name = "buffer" },
                }),
                experimental = {
                    ghost_text = true -- This feature conflicts with copilot.vim's preview.
                }
            })
        end,
    },
}
