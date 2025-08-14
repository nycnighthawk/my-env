return {
  "neovim/nvim-lspconfig", -- or any plugin that is always loaded
  init = function()
    require("my.lsp") -- this will run your autocmd/command registration
  end,
}
