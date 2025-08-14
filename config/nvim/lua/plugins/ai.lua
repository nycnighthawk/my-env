return {
  --[[
  {
    "CopilotC-nVim/CopilotChat.nvim",
    branch = "canary", -- This will use the 'canary' branch
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
      "nvim-lualine/lualine.nvim",
    },
    opts = {
      debug = false,
    },
    config = function()
      require("CopilotChat.integrations.cmp").setup()
      require("CopilotChat").setup({
        mappings = {
          complete = {
            insert = "",
          },
        },
      })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
--]]
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
      },
    },
  },
}
