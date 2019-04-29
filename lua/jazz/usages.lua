-- luacheck: globals unpack vim
local acid = require('acid')
local forms = require('acid.forms')
local commands = require('acid.commands')
local impromptu = require('impromptu')
local log = require('jazz.log').msg

local usages = {}

usages.find_all = function(symbol, ns)
  if not acid.connected() then
    log"No connection present. Aborting"
    return
  end
  symbol = symbol or forms.symbol_under_cursor()
  ns = ns or vim.api.nvim_call_function("AcidGetNs", {})

  local pwd = vim.api.nvim_call_function('getcwd', {})
  local window = vim.api.nvim_get_current_win()
  local winnr = vim.api.nvim_call_function("win_id2win", {window})
  local fname = vim.api.nvim_call_function('expand', {"%:p"})

  local ui = impromptu.filter{
    title = "🎵 Finding usages of [" .. ns .. "/" .. symbol .. "]",
    options = {},
    handler = function(_, obj)
      local data = obj.data.occurrence

      local fpath = data.file
      local col = math.floor(data['col-beg'] or 1)
      local ln = math.floor(data['line-beg'] or 1)

      if fpath ==  fname then
        vim.api.nvim_win_set_cursor(window, {ln, col})
      else
        vim.api.nvim_command(winnr .. "wincmd w | edit +" .. ln .. " " .. fpath)
      end

      return true
    end
  }

  local acid_handler = function(data)
    if data.occurrence ~= nil then
      local descr = (
          data.occurrence.match .. " @ " .. data.occurrence.file .. ":" .. math.floor(data.occurrence['line-beg'])
        ):gsub("\n", "\\n")

      ui:update{description = descr, data = data}
    end
  end

  acid.run(commands.list_usage(acid_handler, symbol, ns, pwd, fname))
end

return usages
