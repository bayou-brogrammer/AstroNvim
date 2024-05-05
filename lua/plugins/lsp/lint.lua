---@type LazySpec
return {
  {
    optional = true,
    "jay-babu/mason-null-ls.nvim",
    opts = {
      methods = { diagnostics = false },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = "User AstroFile",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        fish = { "fish" },
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
        -- ["*"] = { "typos" },
      },
      -- AtomicVim extension to easily override linter options
      -- or add custom linters.
      ---@type table<string,table>
      linters = {
        -- -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   -- `condition` is another AtomicVim extension that allows you to
        --   -- dynamically enable/disable linters based on the context.
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },

    config = function(_, opts)
      local M = {}
      local lint = require "lint"

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.valid_linters(ctx, linters)
        if not linters then return {} end
        return vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          return linter
            and vim.fn.executable(linter.cmd) == 1
            and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, linters)
      end

      lint.linters_by_ft = opts.linters_by_ft or {}
      for name, linter in pairs(opts.linters or {}) do
        local base = lint.linters[name]
        lint.linters[name] = (type(linter) == "table" and type(base) == "table")
            and vim.tbl_deep_extend("force", base, linter)
          or linter
      end

      local orig_resolve_linter_by_ft = lint._resolve_linter_by_ft
      lint._resolve_linter_by_ft = function(...)
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

        local linters = M.valid_linters(ctx, orig_resolve_linter_by_ft(...))
        if not linters[1] then linters = M.valid_linters(ctx, lint.linters_by_ft["_"]) end -- fallback
        require("astrocore").list_insert_unique(linters, M.valid_linters(ctx, lint.linters_by_ft["*"])) -- global

        return linters
      end

      function M.lint()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then vim.list_extend(names, lint.linters_by_ft["_"] or {}) end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then AtomicVim.warn("Linter not found: " .. name, { title = "nvim-lint" }) end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then lint.try_lint(names) end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },
}
