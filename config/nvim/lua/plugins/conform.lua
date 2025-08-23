return {}
--[[
--
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Override or extend formatter mappings
    opts.formatters_by_ft.sh = { "shfmt_custom" }

    -- Custom shfmt formatter
    opts.formatters = {
      shfmt_custom = {
        command = "shfmt",
        args = { "-i", "2", "-ci", "-sr", "-kp" },
        stdin = true,
      },
    }

    return opts
  end,
}
--]]
