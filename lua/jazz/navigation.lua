-- luacheck: globals vim
local acid = require("acid")
local ops = require("acid.ops")
local impromptu = require("impromptu")


--acid.run(ops['ns-load-all']{})
local navigation = {}

navigation.symbols = function(ns)
  if ns == nil then
    local current_ns = vim.api.nvim_call_function("AcidGetNs", {})
    local root

    for part in string.gmatch(current_ns, "(%w+)") do
      root = part
      break
    end

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

        local fpath = vim.api.nvim_call_function("AcidFindFileInPath", {ret})
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
