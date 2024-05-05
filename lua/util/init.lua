local LazyUtil = require "lazy.core.util"

local M = {}

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then return LazyUtil[k] end
    t[k] = require("util." .. k)
    return t[k]
  end,
})

function M.is_win() return vim.uv.os_uname().sysname:find "Windows" ~= nil end

---@param plugin string
function M.has(plugin) return require("lazy.core.config").spec.plugins[plugin] ~= nil end

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function() fn() end,
  })
end

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
      require("astrolsp").on_attach(client, buffer)
    end,
  })
end

return M
