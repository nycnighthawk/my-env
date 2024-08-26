return {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      {
        'ahmedkhalf/project.nvim',
        dependencies = { 'nvim-tree/nvim-tree.lua' },
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
      },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['file_browser'] = {
            hijack_netrw = true,
          },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          ['aerial'] = {
            format_symbol = function(symbol_path, filetype)
              if filetype == "json" or filetype == "yaml" then
                return table.concat(symbol_path, ".")
              else
                return symbol_path[#symbol_path]
              end
            end,
            -- Available modes: symbols, lines, both
            show_columns = "both",
          },
        }
      }
      pcall(require('telescope').load_extension, 'file_browser')
      pcall(require('telescope').load_extension, 'projects')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'aerial')
    end,
  },
}
