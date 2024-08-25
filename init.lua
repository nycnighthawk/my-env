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
  {"nvim-lua/plenary.nvim"},
  {"nvim-lua/popup.nvim"},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'neovim/nvim-lspconfig'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'hrsh7th/cmp-buffer'},
  {'hrsh7th/cmp-path'},
  {'L3MON4D3/LuaSnip'},
  {'saadparwaiz1/cmp_luasnip'},
  {'nvim-telescope/telescope.nvim', branch='0.1.x',
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
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({buffer = bufnr})
end)
require('mason').setup({})
---[[
local lsp_list = {}
--]]
--[[
local lsp_list = {"lua_ls", "rust_analyzer", "pyright", "tsserver",
    "ast_grep", "ansiblels", "autotools_ls", "awk_ls", "csharp_ls",
    "harper_ls", "ruby_lsp", "gopls"}
--]]
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
  ensure_installed = lsp_list,
})
require('lspconfig').lua_ls.setup({})
-- require('lspconfig').pyright.setup({})
-- require('lspconfig').tsserver.setup({})
vim.cmd.source(vim.fn.stdpath("config") .. "/my-vim-settings/myvim_init.vim")
vim.cmd.source(vim.fn.stdpath("config") .. "/my-vim-settings/myvim_init_2.vim")
