local plugins = {
  {"nvim-lua/plenary.nvim"},
  {"nvim-lua/popup.nvim"},
  require 'mynvim.plugins.cmp',
  require 'mynvim.plugins.telescope',
  require 'mynvim.plugins.nvim-tree',
  require 'mynvim.plugins.lsp-zero',
  {"vim-airline/vim-airline"},
  {"folke/tokyonight.nvim"},
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
      "github/copilot.vim",
    },
    opts = {
      debug = false,
    },
  },
  {
      "echasnovski/mini.nvim", version = '*',
  },
  {"sheerun/vim-polyglot"},
  {"junegunn/fzf"},
  {"junegunn/fzf.vim"},
  {"webdevel/tabulous"},
  {"preservim/tagbar"},
}
require("lazy").setup(plugins, opts)
