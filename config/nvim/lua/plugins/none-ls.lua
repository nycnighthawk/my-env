return {}
--[[
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- Remove shfmt if it exists
    opts.sources = vim.tbl_filter(function(source)
      return source.name ~= "shfmt"
    end, opts.sources or {})
  end,
}
]]
