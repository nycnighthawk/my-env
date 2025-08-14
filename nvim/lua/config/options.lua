-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_fonts = true
-- vim.opt.relativenumber = false
-- vim.opt.clipboard = "unnamedplus"
vim.opt.clipboard = ""
vim.opt.timeoutlen = 450
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.g.lazyvim_blink_main = false

-- set ctag file to use .tags instead of tags
vim.g.gutentags_ctags_tagfile = ".tags"
