return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "black" },
      lua = { "stylua" }, -- example: stylua for lua files
      sh = { "shfmt" }, -- example: shfmt for shell scripts
      -- add more filetypes/formatters as needed
    },
  },

  keys = {
    {
      "<leader>F",
      function()
        require("conform").format({ async = true })
      end,
      mode = "n",
      desc = "Format buffer with conform.nvim",
    },
    {
      "<leader>F",
      function()
        local start_row = vim.fn.line("v")
        local end_row = vim.fn.line(".")
        -- Ensure start_row <= end_row
        if start_row > end_row then
          start_row, end_row = end_row, start_row
        end
        require("conform").format({
          async = true,
          range = { start = { start_row, 1 }, ["end"] = { end_row, 1 } },
        })
      end,
      mode = "v",
      desc = "Format selection with conform.nvim",
    },
  },
}
