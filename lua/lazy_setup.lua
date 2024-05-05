_G.AtomicVim = require "util"

---@type LazySpec
local lazy_spec = {
  {
    "AstroNvim/AstroNvim",
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
    },
  },

  { import = "community" },
  { import = "plugins" },
}

---@type LazyConfig
local lazy_cfg = {
  ui = { backdrop = 100 },
  install = {
    colorscheme = { "astrodark", "habamax", "fluoromachine" },
  },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
}

require("lazy")--[[@as Lazy]]
  .setup(lazy_spec, lazy_cfg)
