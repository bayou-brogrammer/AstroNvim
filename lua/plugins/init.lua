AtomicVim.format.setup()

-- local disabled = {}

-- for _, plugin in ipairs(AtomicVim.plugins) do
--   if plugin.disable then disabled[#disabled + 1] = plugin.name end
-- end

-- if #disabled > 0 then
--   AtomicVim.warn(
--     "Disabled plugins: " .. table.concat(disabled, ", ") .. "\n" .. "To enable, run: lazy install",
--     { title = "LazyVim" }
--   )
-- end

return {
  { import = "plugins.astro" },
  { import = "plugins.lang" },
  { import = "plugins.lsp" },
}
