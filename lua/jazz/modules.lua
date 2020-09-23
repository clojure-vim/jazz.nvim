-- luacheck: globals vim
-- TODO Add optional alias
local acid = require("acid")
local ops = require("acid.ops")
local impromptu = require("impromptu")
local features = require("acid.features")

local modules = {}

modules.select_add_require = function()

  local winnr = vim.api.nvim_get_current_win()

  local filter = impromptu.filter{
    title = "🎵 Add :require dependency",
    options = {},
    handler = function(_, selected)
      vim.api.nvim_set_current_win(winnr)
      features.add_require(selected.description)
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
