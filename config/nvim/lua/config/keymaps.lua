-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "zh", "<cmd>let &hls=!&hls<CR>")
vim.keymap.set("i", "kj", "<Esc>", { silent = true, noremap = true })
