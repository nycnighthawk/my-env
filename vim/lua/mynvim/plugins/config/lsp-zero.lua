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
