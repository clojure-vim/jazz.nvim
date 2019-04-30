-- luacheck: globals vim
local log = {}

log.msg = function(...)
  vim.api.nvim_out_write("[Jazz] " .. table.concat({...}, " ") .. "\n")
end

return log
