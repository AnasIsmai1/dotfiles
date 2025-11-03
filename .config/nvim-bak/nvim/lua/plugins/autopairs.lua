return {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },

    config = function()
        local npairs = require("nvim-autopairs")
        npairs.setup({
            ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
            check_ts = true,
            ts_config = {
                lua = { "string" }, -- it will not add a pair on that treesitter node
                javascript = { "template_string" },
                java = false,       -- don't check treesitter on java
            },
            disable_filetype = { "TelescopePrompt" },
            fast_wrap = {
                map = "<M-e>",
                chars = { "{", "[", "(", '"', "'", "<" },
                pattern = [=[[%'%"%>%]%)%}%,]]=],
                end_key = "$",
                before_key = "h",
                after_key = "l",
                cursor_pos_before = true,
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                manual_position = true,
                highlight = "Search",
                highlight_grey = "Comment",
            },
        })
    end,
}
