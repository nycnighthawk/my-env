local plugins = {
  {"nvim-lua/plenary.nvim"},
  {"nvim-lua/popup.nvim"},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'neovim/nvim-lspconfig'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  require 'mynvim.plugins.cmp',
  {'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
  },
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
