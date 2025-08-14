local M = {}
function M.SourceBuffer()
  local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- Join the lines into a single string
  local lua_code = table.concat(buffer_content, "\n")
  -- Execute the Lua code
  local func, err = loadstring(lua_code)
  if func then
    func()
  else
    print("Error loading Lua code: " .. err)
  end
end

function M.SourceVisualSelection()
  -- Get the start and end positions of the visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  -- Extract the selected lines
  local selected_lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  -- Join the lines into a single string
  local lua_code = table.concat(selected_lines, "\n")
  -- Execute the Lua code
  local func, err = loadstring(lua_code)
  if func then
    func()
  else
    print("Error loading Lua code: " .. err)
  end
end

vim.api.nvim_create_user_command("LuaSourceBuffer", M.SourceBuffer, {})
vim.api.nvim_create_user_command("LuaSourceVisual", M.SourceVisualSelection, {})

return M
