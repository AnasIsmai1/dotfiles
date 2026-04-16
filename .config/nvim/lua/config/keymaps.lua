-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remap for navigating to first/last word
vim.keymap.set({ "n", "v", "x" }, "gf", "^", { desc = "go to first non-blank character" })
vim.keymap.set({ "n", "v", "x" }, "ge", "g_", { desc = "go to last non-blank character" })

vim.keymap.set({ "n", "v", "x" }, "<C-S>", "gg0vGg_", { remap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<leader>ww", ":wa<CR>", { silent = true, desc = "save and format file" })
vim.keymap.set({ "n", "v" }, "<leader>wq", ":wq<CR>", { silent = true, desc = "save and quit file" })
vim.keymap.set({ "n", "v" }, "<leader>qq", ":q!<CR>", { silent = true, desc = "quit all files w/o saving" })
vim.keymap.set({ "n", "v" }, "<leader>q", ":qa<CR>", { silent = true, desc = "save and exit file" })
vim.keymap.set("i", "kj", "<ESC>", { desc = "Enter and Exit normal mode" })

-- Map <Tab>/<S-Tab> to indent/unindent the current line in normal mode
vim.keymap.set("n", "<Tab>", ":normal! >>llll<CR>", { noremap = true, silent = true, desc = "Tab" })
vim.keymap.set("n", "<S-Tab>", ":normal! <<hhhh<CR>", { noremap = true, silent = true, desc = "Un-Tab" })

vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, silent = true, desc = "Tab" })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true, desc = "Un-Tab" })

-- CodeSnaps
vim.keymap.set("n", "<leader>c", "", { desc = "CodeSnaps" })

-- Map <leader> L to open Lazy
vim.keymap.set("n", "<leader>L", ":Lazy<CR>", { silent = true, desc = "Open Lazy" })

-- Clear Search Higlights
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { silent = true, desc = "Clear Search Higlights" })

-- Increment/Decrement Numbers
vim.keymap.set("n", "<leader>+", "<c-a>", { silent = true, desc = "Increment number" }) --increment
vim.keymap.set("n", "<leader>-", "<c-x>", { silent = true, desc = "Decrement number" }) --decrement

-- Window Management
vim.keymap.set("n", "<leader>s", "", { desc = "Splits" })
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Open Vertical Splits" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Open Horizontal Splits" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close Current Split" })

-- Tab Management
vim.keymap.set("n", "<leader>t", "", { desc = "Tabs" })
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open New Tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close Current Tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go To Next Tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go To Previous Tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open Current Buffer In New Tab" })

-- Move Text Up and Down
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv-gv", { desc = "Move Line Up" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv-gv", { desc = "Move Line Down" })
vim.keymap.set("v", "p", '"_dP', { silent = true, noremap = true })

vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move Lines Up", silent = true })
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move Lines Up", silent = true })
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move Lines Up", silent = true })
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move Lines Down", silent = true })

-- Resize Split Panes
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })

-- Remove or Sort Import in ts files
vim.keymap.set("n", "<leader>o", "<cmd>OrganizeImports<CR>", { desc = "Organize Imports within TS files" })

-- Move to previously visited buffer;
vim.keymap.set("n", "<leader><leader>", "<C-6>", { desc = "Alternate Buffer" })

-- Exit terminal mode in vim
vim.keymap.set("n", "<Esc>", "<C-\\><C-n>", { noremap = true, desc = "Exit terminal mode in vim" })
