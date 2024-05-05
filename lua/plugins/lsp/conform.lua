return {
  {
    "AstroNvim/astrolsp",
    opts = { formatting = { disabled = true } },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = { methods = { formatting = false } },
  },
  {
    "stevearc/conform.nvim",
    event = "User AstroFile",
    cmd = "ConformInfo",
    dependencies = {
      { "williamboman/mason.nvim" },

      {
        "AstroNvim/astrocore",
        opts = {
          options = { opt = { formatexpr = "v:lua.require'conform'.formatexpr()" } },
          commands = {
            Format = {
              function(args)
                local range = nil
                if args.count ~= -1 then
                  local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                  range = {
                    start = { args.line1, 0 },
                    ["end"] = { args.line2, end_line:len() },
                  }
                end
                require("conform").format { async = true, lsp_fallback = true, range = range }
              end,
              desc = "Format buffer",
              range = true,
            },
          },
          mappings = {
            n = {
              ["<Leader>lf"] = { function() vim.cmd.Format() end, desc = "Format buffer" },
              ["<Leader>uf"] = {
                function()
                  if vim.b.autoformat == nil then
                    if vim.g.autoformat == nil then vim.g.autoformat = true end
                    vim.b.autoformat = vim.g.autoformat
                  end
                  vim.b.autoformat = not vim.b.autoformat
                  require("astrocore").notify(
                    string.format("Buffer autoformatting %s", vim.b.autoformat and "on" or "off")
                  )
                end,
                desc = "Toggle autoformatting (buffer)",
              },
              ["<Leader>uF"] = {
                function()
                  if vim.g.autoformat == nil then vim.g.autoformat = true end
                  vim.g.autoformat = not vim.g.autoformat
                  vim.b.autoformat = nil
                  require("astrocore").notify(
                    string.format("Global autoformatting %s", vim.g.autoformat and "on" or "off")
                  )
                end,
                desc = "Toggle autoformatting (global)",
              },
            },
          },
        },
      },
    },

    init = function()
      -- Install the conform formatter on VeryLazy
      AtomicVim.on_very_lazy(function()
        AtomicVim.format.register {
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf)
            local plugin = require("lazy.core.config").plugins["conform.nvim"]
            local Plugin = require "lazy.core.plugin"
            local opts = Plugin.values(plugin, "opts", false)
            require("conform").format(AtomicVim.merge({}, opts.format, { bufnr = buf }))
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v) return v.name end, ret)
          end,
        }
      end)
    end,

    opts = {
      format_on_save = function(bufnr)
        if vim.g.autoformat == nil then vim.g.autoformat = true end
        local autoformat = vim.b[bufnr].autoformat
        if autoformat == nil then autoformat = vim.g.autoformat end
        if autoformat then return { timeout_ms = 500, lsp_fallback = true } end
      end,

      -- AtomicVim will use these options when formatting with the conform.nvim formatter
      format = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_fallback = true, -- not recommended to change
      },
      ---@type table<string, conform.FormatterUnit[]>
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
    },
  },
}
