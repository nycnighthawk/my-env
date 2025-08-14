return {
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.has_nerd_fonts,
    lazy = false,
    config = function()
      require("nvim-web-devicons").setup({})
    end,
  },
}
