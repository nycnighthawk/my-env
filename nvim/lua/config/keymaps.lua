-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local my_funcs = require("config.my_funcs")
vim.keymap.set("n", "zh", "<cmd>let &hls=!&hls<CR>")
vim.keymap.set("i", "kj", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>gsb", my_funcs.SourceBuffer, { noremap = true, silent = true })
vim.keymap.set(
  "i",
  "<C-f>sb",
  "<Esc>:lua require('config.my_funcs').SourceBuffer()<CR>",
  { noremap = true, silent = true }
)
vim.keymap.set("v", "<leader>gsb", my_funcs.SourceVisualSelection, { noremap = true, silent = true })
