-- luacheck: globals vim
local utils = require("jazz.utils")
local impromptu = require("impromptu")

local files = {}

files.alternate = function(file)
  file = file or vim.api.nvim_call_function("expand", {"%:p"})
  local window = vim.api.nvim_get_current_win()
  local ns = vim.api.nvim_call_function("AcidGetNs", {file})
  local alternates = vim.api.nvim_call_function("AcidAlternateFiles", {file})

  if utils.ends_with(ns, "-test") then
    ns = ns:sub(1, -5)
  else
    ns = ns .. "-test"
  end

  if #alternates == 0 then
    return
  elseif #alternates == 1 then
      files.new(ns, alternates[1], window)
  else
    impromptu.filter{
      title = "🎵 Select which possible alternate file to create:",
      options = utils.map(function(itm) return {description = itm} end, alternates),
      handler = function(_, result)
        files.new(ns, result.description, window)
        return true
      end
  }
  end
end

files.new = function(ns, fname, window)
  ns = ns or vim.api.nvim_call_function("AcidGetNs", {})
  window = window or vim.api.nvim_get_current_win()
  local winnr = vim.api.nvim_call_function("win_id2win", {window})
  local fpath = vim.api.nvim_call_function("AcidNewFile", {ns, fname})
  vim.api.nvim_command(winnr .. "wincmd w | edit " .. fpath)
end



return files
