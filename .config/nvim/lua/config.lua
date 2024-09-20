vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.opt.expandtab = true
vim.opt.autoindent = true

vim.g.mapleader = " "
vim.keymap.set({ "n", "v" }, "<leader>ww", ":wa<CR>", { silent = true, desc = "save and format file" })
vim.keymap.set({ "n", "v" }, "<leader>q", ":qa<CR>", { silent = true, desc = "save and exit file" })
vim.keymap.set("i", "kj", "<ESC>", { desc = "Enter and Exit normal mode" })
-- Map <Tab> to indent the current line in normal mode
vim.keymap.set({ "n", "v" }, "<Tab>", ":normal! >>ll<CR>", { noremap = true, silent = true, desc = "Tab" })

-- Map <S-Tab> to un-indent the current line in normal mode
vim.keymap.set({ "n", "v" }, "<S-Tab>", ":normal! <<hh<CR>", { noremap = true, silent = true, desc = "Un-Tab" })

-- Map <leader> L to open Lazy
vim.keymap.set("n", "<leader>L", ":Lazy<CR>", { silent = true, desc = "Open Lazy" })

-- Clear Search Higlights
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { silent = true, desc = "Clear Search Higlights" })

-- Increment/Decrement Numbers
vim.keymap.set("n", "<leader>+", "<c-a>", { silent = true, desc = "Increment number" }) --increment
vim.keymap.set("n", "<leader>-", "<c-x>", { silent = true, desc = "Decrement number" }) --decrement

-- Window Management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Open Vertical Splits" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Open Horizontal Splits" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close Current Split" })

-- Tab Management
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open New Tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close Current Tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go To Next Tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go To Previous Tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open Current Buffer In New Tab" })

-- Move Text Up and Down
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv-gv", { desc = "Move Line Up" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv-gv", { desc = "Move Line Down" })
vim.keymap.set("v", "p", '"_dP', { silent = true, noremap = true })

vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move Lines Up" })
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move Lines Up" })
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move Lines Up" })
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move Lines Down" })

-- Resize Split Panes
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })

-- Remove or Sortt Import in ts files
vim.keymap.set('n', '<leader>o', '<cmd>OrganizeImports<CR>', { desc="Organize Imports within TS files"})

-- Set the line number relative to the current line
vim.opt.relativenumber = true
vim.opt.number = true
-- Set the width of the line numberl column to 6 characters
vim.opt.numberwidth = 4

-- Ensure there is enough space for the line number column
vim.opt.signcolumn = "yes"

-- Adjust the column width for signs (e.g., for linting or git signs)
vim.api.nvim_set_hl(0, "SignColumn", { fg = "Grey" })


-- Move in between pane
--vim.keymap.set('n', '<c-l>', ':wincmd l<CR>', {silent = true, desc="Navigate Right"})
--vim.keymap.set('n', '<c-k>', ':wincmd k<CR>', {silent = true, desc="Navigate Up"})
--vim.keymap.set('n', '<c-j>', ':wincmd j<CR>', {silent = true, desc="Navigate Down"})
--vim.keymap.set('n', '<c-h>', ':wincmd h<CR>', {silent = true, desc="Navigate Left"})

vim.opt.wrap = false

-- search settings
vim.opt.smartcase = true  -- ignore case when searching
vim.opt.ignorecase = true -- if you include mixed case in your search, assumes you want case-insensitive

vim.opt.cursorline = true

vim.opt.background = "dark"
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
