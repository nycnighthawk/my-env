return {
  {
    "ludovicchabant/vim-gutentags",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Gutentags configuration
      vim.g.gutentags_project_root =
        { ".git", ".hg", ".svn", "Makefile", "package.json", "src", "README.md", "LICENSE" }
      vim.g.gutentags_ctags_tagfile = ".tags"
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_missing = 1
    end,
  },
}
