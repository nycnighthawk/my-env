local pyright_switcher = require("my.lsp.pyright_switcher")

local group = vim.api.nvim_create_augroup("PyrightSwitcherCmd", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = group,
  callback = function(args)
    -- Only create the command if it doesn't already exist for this buffer
    local ok = pcall(vim.api.nvim_buf_get_user_command, args.buf, "PyrightSwitchPython")
    if not ok then
      vim.api.nvim_buf_create_user_command(args.buf, "PyrightSwitchPython", function(cmd_args)
        pyright_switcher.PyrightSwitchPython(cmd_args)
      end, { nargs = 1, complete = "file" })
    end
  end,
  desc = "Add PyrightSwitchPython command to python buffers",
})
