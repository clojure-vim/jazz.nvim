-- luacheck: globals unpack vim
local acid = require('acid')
local ops = require('acid.commands').ops
local features = require('acid.features')
local impromptu = require("impromptu")

local jazz = {}

local low_level = {}

low_level.ends_with = function(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

jazz.find_usages = function(symbol, ns)
  symbol = symbol or vim.api.nvim_call_function("expand", {"<cword>"})
  ns = ns or vim.api.nvim_call_function("AcidGetNs", {})
  local cb = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_call_function("bufwinnr", {cb})
  local pwd = vim.api.nvim_call_function('getcwd', {})
  local fname = vim.api.nvim_call_function('expand', {"%:p"})


  local ui = impromptu.filter{
    title = "🎵 Finding usages of [" .. ns .. "/" .. symbol .. "]",
    options = {},
    handler = function(_, obj)
      local data = obj.data.occurrence

      local fpath = data.file
      local col = math.floor(data['col-beg'] or 1)
      local ln = math.floor(data['line-beg'] or 1)

      local cur_scroll = vim.api.nvim_get_option("scrolloff")
      vim.api.nvim_set_option("scrolloff", 999)

      if low_level.ends_with(vim.api.nvim_call_function("expand", {"%"}), fpath) then
        vim.api.nvim_call_function("cursor", {ln, col})
      else
        vim.api.nvim_command(winnr .. "wincmd w | new +" .. ln .. " " .. fpath)
      end
      vim.api.nvim_set_option("scrolloff", cur_scroll)

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

  acid.run(features.list_usage(acid_handler, symbol, ns, pwd, fname))
end

jazz.require_all = function()
  acid.run(ops['ns-load-all']{})
end

--vim.api.nvim_command("command! -nargs=0 RequireAll lua jazz.require_all()")
vim.api.nvim_command("command! -nargs=? JazzFindUsages lua jazz.find_usages(<f-args>)")
