local M = {}

function M.set_python_path(python_path)
  local bufnr = vim.api.nvim_get_current_buf()
  local lspconfig = require("lspconfig")
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local restarted = false

  for _, client in ipairs(clients) do
    if client.name == "pyright" then
      client:stop()
      -- Update the config for future attaches
      lspconfig.pyright.setup({
        settings = {
          python = {
            pythonPath = python_path,
          },
        },
      })
      -- Restart the LSP for this buffer
      vim.defer_fn(function()
        vim.cmd("edit")
        vim.notify("Pyright restarted with python: " .. python_path, vim.log.levels.INFO)
      end, 500)
      restarted = true
      break
    end
  end

  if not restarted then
    vim.notify("Pyright LSP not attached to this buffer.", vim.log.levels.WARN)
  end
end

-- Command handler
function M.PyrightSwitchPython(args)
  local python_path = args.args
  if python_path == "" then
    vim.notify("Please provide a python executable path.", vim.log.levels.ERROR)
    return
  end
  local resolved_python_path = vim.fn.fnamemodify(python_path, ":p")
  if vim.fn.executable(resolved_python_path) == 0 then
    vim.notify("The provided path is not executable: " .. resolved_python_path, vim.log.levels.ERROR)
    return
  end
  M.set_python_path(resolved_python_path)
end

return M
