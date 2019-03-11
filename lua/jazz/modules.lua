-- luacheck: globals vim
local acid = require("acid")
local ops = require("acid.ops")
local impromptu = require("impromptu")

local modules = {}

modules.select_add_require = function()

  local bufnr = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_call_function("bufwinnr", {bufnr})

  local filter = impromptu.filter{
    title = "🎵 Add :require dependency",
    options = {},
    handler = function(_, selected)
      vim.api.nvim_command(winnr .. "wincmd w")
      vim.api.nvim_call_function("AcidFnAddRequire", {selected.description})
      return true
    end
  }

  acid.run(ops['ns-list']{}:with_handler(function(ret)
    for _, namespace in ipairs(ret['ns-list']) do
        filter:update{
          description = "[" .. namespace .. "]",
        }
      end

  end))

end

return modules
