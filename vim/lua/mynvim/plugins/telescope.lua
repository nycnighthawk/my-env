return {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        extensions = {
          file_browser = {
            hijack_netrw = true,
          },
        }
      }
      require('telescope').load_extension('file_browser')
      require('telescope').load_extension('projects')
    end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  },
  {
    'ahmedkhalf/project.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-tree/nvim-tree.lua' },
    config = function()
      require('nvim-tree').setup({
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true
        },
      })
      require('project_nvim').setup {
      }
    end,
  }
}
