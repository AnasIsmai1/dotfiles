local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = "git@github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- debug logs
-- vim.lsp.set_log_level("debug")

require("config")
require("options")
require("lazy").setup("plugins", {
    git = {
        timeout = 200,
        shallow = true,
    },
    checker = {
        enabled = true,
        notify = false
    },
    change_detection = {
        notify = true
    },
})
