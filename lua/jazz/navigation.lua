-- luacheck: globals vim
local acid = require("acid")
local ops = require("acid.ops")
local impromptu = require("impromptu")
local log = require("jazz.log").msg


local navigation = {}

navigation.symbols = function(ns)
  if not acid.connected() then
    log"No connection present. Aborting"
    return
  end
  if ns == nil then
    local current_ns = vim.api.nvim_call_function("AcidGetNs", {})
    local root = string.match(current_ns, "(%w+)")

    if root ~= nil then
      ns = root
    end

  end
  local bufnr = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_call_function("bufwinnr", {bufnr})
  local window = vim.api.nvim_call_function("win_getid", {winnr})

  local filter = impromptu.filter{
    title = "🎵 Navigate to symbols",
    options = {},
    handler = function(_, selected)
      acid.run(ops["info"]{ns = selected.ns, symbol = selected.var}:with_handler(function(ret)

        local fpath = vim.api.nvim_call_function("AcidFindFileInPath", {ret.file, ret.resource})
        vim.api.nvim_command("edit " .. fpath)

        vim.api.nvim_win_set_cursor(window, {ret.line, ret.column})

      end))
      return true
    end
  }

  acid.run(ops['ns-list']{['filter-regexps'] = {'^(?!' .. ns .. '.*)'}}:with_handler(function(ret)
    for _, namespace in ipairs(ret['ns-list']) do
      acid.run(ops['ns-vars']{ns = namespace}:with_handler(function(vars)
        for _, var in ipairs(vars['ns-vars']) do

          filter:update{
            description = namespace .. "/" .. var,
            ns = namespace,
            var = var
          }
        end

      end))
    end
  end))

end

return navigation
