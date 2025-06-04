return {
    {
        'Exafunction/codeium.nvim',
        enabled = false,
        event = { "InsertEnter", "BufReadPre" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("codeium").setup({})
        end
    },
    {
        'augmentcode/augment.vim',
        enabled = false
    },
    {
        'github/copilot.vim',
        -- enabled = false,
        event = { "InsertEnter", "BufReadPre" },
        config = function()
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
            -- choose next suggestion copilot
            vim.api.nvim_set_keymap("i", "<C-]>", 'copilot#Next()', { silent = true, expr = true })
            -- choose previous suggestion copilot
            vim.api.nvim_set_keymap("i", "<C-[>", 'copilot#Previous()', { silent = true, expr = true })
        end
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        cmd = "CopilotChat",
        opts = function()
            local user = vim.env.USER or "User"
            user = user:sub(1, 1):upper() .. user:sub(2)
            return {
                model = "claude-3.7-sonnet",
                auto_insert_mode = true,
                question_header = "  " .. user .. " ",
                answer_header = "  Copilot ",
                window = {
                    width = 0.4,
                },
            }
        end,
        keys = {
            { "<c-s>",     "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
            { "<leader>a", "",     desc = "+ai",        mode = { "n", "v" } },
            {
                "<leader>aa",
                function()
                    return require("CopilotChat").toggle()
                end,
                desc = "Toggle (CopilotChat)",
                mode = { "n", "v" },
            },
            {
                "<leader>ax",
                function()
                    return require("CopilotChat").reset()
                end,
                desc = "Clear (CopilotChat)",
                mode = { "n", "v" },
            },
            {
                "<leader>aq",
                function()
                    vim.ui.input({
                        prompt = "Quick Chat: ",
                    }, function(input)
                        if input ~= "" then
                            require("CopilotChat").ask(input)
                        end
                    end)
                end,
                desc = "Quick Chat (CopilotChat)",
                mode = { "n", "v" },
            },
            {
                "<leader>ap",
                function()
                    require("CopilotChat").select_prompt()
                end,
                desc = "Prompt Actions (CopilotChat)",
                mode = { "n", "v" },
            },
        },
        config = function(_, opts)
            local chat = require("CopilotChat")

            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "copilot-chat",
                callback = function()
                    vim.opt_local.relativenumber = false
                    vim.opt_local.number = false
                end,
            })

            chat.setup(opts)
        end,
    },
}
