AtomicVim.format.setup()

-- local disabled_plugins = {
--   "nvimtools/none-ls.nvim",
-- }

local imports = {
  "plugins.astro",
  "plugins.lang",
  "plugins.lsp",
}

-- -- Add disabled plugins to imports
-- for _, disabled in ipairs(disabled_plugins) do
--   table.insert(imports, { disabled, enabled = false })
-- end

return imports
