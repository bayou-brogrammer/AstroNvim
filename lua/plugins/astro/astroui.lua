function setup_schemes()
  local fm = require "fluoromachine"

  fm.setup {
    glow = true,
    theme = "retrowave",
  }
end

---@type LazySpec
return {
  "maxmx03/fluoromachine.nvim",

  {
    "AstroNvim/astroui",

    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = "fluoromachine",
      -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
      highlights = {
        init = { -- this table overrides highlights in all themes
          -- Normal = { bg = "#000000" },
        },
        astrotheme = { -- a table of overrides/changes when applying the astrotheme theme
          -- Normal = { bg = "#000000" },
        },
      },
      -- Icons can be configured throughout the interface
      icons = {
        -- configure the loading of the lsp in the status line
        LSPLoading1 = "⠋",
        LSPLoading2 = "⠙",
        LSPLoading3 = "⠹",
        LSPLoading4 = "⠸",
        LSPLoading5 = "⠼",
        LSPLoading6 = "⠴",
        LSPLoading7 = "⠦",
        LSPLoading8 = "⠧",
        LSPLoading9 = "⠇",
        LSPLoading10 = "⠏",
      },
    },

    config = function(_, opts)
      setup_schemes()
      require("astroui").setup(opts)
    end,
  },
}
