vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.showcmdloc = 'statusline'
vim.g.mapleader = " "
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.statuscolumn = '%s %l  %C  '                    -- set format of column (-signColumn -lineColumn-foldColumn)
vim.opt.foldcolumn = "auto"
vim.opt.numberwidth = 2                                 -- Set the width of the line numberl column to 6 characters
vim.opt.signcolumn = "yes"                              -- Ensure there is enough space for the line number column
vim.api.nvim_set_hl(0, "SignColumn", { fg = "silver" }) -- Adjust the column width for signs (e.g., for linting or git signs)
-- vim.o.foldmethod = 'indent'-- Add fold capabilites
-- vim.o.foldexpr = "v:lua require('lazyvim.util').ui.foldexpr()"
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = false
vim.o.foldtext = ""
vim.opt.guicursor = ""
vim.opt.wrap = true
-- search settings
vim.opt.smartcase = true  -- ignore case when searching
vim.opt.ignorecase = true -- if you include mixed case in your search, assumes you want case-insensitive
vim.opt.cursorline = true
vim.opt.background = "light"
vim.opt.termguicolors = true
-- backspace
-- vim.opt.backspace = "indent, eol, start" -- allow backspace on indent, end of line or insert mode start position
--clipboard
vim.opt.clipboard:append("unnamedplus")
--split windows
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.title = true
vim.opt.hlsearch = true
-- autoreload on file changes
vim.opt.autoread = true
-- set the workspace path for augement ai
vim.g.augment_workspace_folders = { '~/Desktop/Nuclear Codes/codesinc/mantis-free-LMS-SuperAdmin/',
    '~/Desktop/Nuclear Codes/artspire-backend/', '~/.config/nvim/', '~/Desktop/Nuclear Codes/finances/' }
vim.g.dbs = {
    {
        name = 'dev',
        url = 'mysql://root:Anas%231234@localhost:3306/mysql'
    },
    {
        name = 'production',
        url = 'mysql://user:password@prodserver:3306/proddb'
    },
}
vim.g.db_ui_adapter = 'mysql' -- or 'postgres' depending on your database

-- Using different colors, defining the colors in this file
-- local colors = require("config.colors").load_colors()
vim.cmd(string.format([[highlight WinBar1 guifg=%s]], "#fff"))
vim.cmd(string.format([[highlight WinBar2 guifg=%s]], "#7dcfff"))
-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
    local full_path = vim.fn.expand("%:p")
    return full_path:gsub(vim.fn.expand("$HOME"), "~")
end
-- Function to get the number of open buffers using the :ls command
local function get_buffer_count()
    local buffers = vim.fn.execute("ls")
    local count = 0
    -- Match only lines that represent buffers, typically starting with a number followed by a space
    for line in string.gmatch(buffers, "[^\r\n]+") do
        if string.match(line, "^%s*%d+") then
            count = count + 1
        end
    end
    return count
end
-- Function to update the winbar
local function update_winbar()
    local home_replaced = get_winbar_path()
    local buffer_count = get_buffer_count()
    vim.opt.winbar = "%#WinBar1#%m "
        .. "%#WinBar2#("
        .. buffer_count
        .. ") "
        .. "%#WinBar1#"
        .. home_replaced
        .. "%*%=%#WinBar2#"
        .. vim.fn.systemlist("hostname")[1]
end
-- Autocmd to update the winbar on BufEnter and WinEnter events
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    callback = update_winbar,
})
