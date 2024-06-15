local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  {"vim-airline/vim-airline"},
  {"vim-airline/vim-airline-themes"},
  {"romgrk/doom-one.vim"},
  {"ludovicchabant/vim-gutentags"},
  {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      vim.cmd [[TSUpdate]]  -- This will run :TSUpdate in Vimscript
    end
  },
  {"tpope/vim-surround"},
  {"tpope/vim-fugitive"},
  {"tpope/vim-commentary"},
  {"github/copilot.vim"},
  {
    "CopilotC-nVim/CopilotChat.nvim",
    branch = 'canary',  -- This will use the 'canary' branch
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
    },
    opts = {
      debug = true,
    },
  },
  {"nvim-lua/plenary.nvim"},
  {"sheerun/vim-polyglot"},
  {"junegunn/fzf"},
  {"junegunn/fzf.vim"},
  {"webdevel/tabulous"},
  {"preservim/tagbar"},
}

require("lazy").setup(plugins, opts)
vim.cmd.source(vim.fn.stdpath("config") .. "/myvim-settings/myvim_init.vim")
vim.cmd.source(vim.fn.stdpath("config") .. "/myvim-settings/myvim_init_2.vim")
