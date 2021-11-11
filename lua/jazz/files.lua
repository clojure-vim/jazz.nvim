-- luacheck: globals vim
local utils = require("jazz.utils")
local impromptu = require("impromptu")

local files = {}

files.alternate = function(file)
  file = file or vim.api.nvim_call_function("expand", {"%:p"})
  local window = vim.api.nvim_get_current_win()
  local ns = vim.api.nvim_call_function("AcidGetNs", {file})
  local alternates = vim.api.nvim_call_function("AcidAlternateFiles", {file})

  local new = function(ns, fname)
    vim.api.nvim_call_function("AcidNewFile", {ns, fname})
    vim.api.nvim_set_current_win(winnr)
    vim.api.nvim_command("edit " .. fname)
  end

  if utils.ends_with(ns, "-test") then
    ns = ns:sub(1, -5)
  else
    ns = ns .. "-test"
  end

  if #alternates == 0 then
    return
  elseif #alternates == 1 then
      new(ns, alternates[1], window)
  else
    impromptu.filter{
      title = "🎵 Select which possible alternate file to create:",
      options = utils.map(function(itm) return {description = itm} end, alternates),
      handler = function(_, result)
        new(ns, result.description, window)
        return true
      end
  }
  end
end

files.new = function(window)
  window = window or vim.api.nvim_get_current_win()
    impromptu.form{
      title = "🎵 New file's namespace:",
      options = {ns = {description = "Namespace"}},
      handler = function(_, result)
        local fpath = vim.fn.AcidNewFile(result.ns)
        if fpath == nil then
          fpath = tap(vim.fn.AcidNewFile(result.ns))
        end
        vim.api.nvim_set_current_win(winnr)
        vim.api.nvim_command("edit " .. fpath)
        return true
      end
  }

end



return files
