local utils = {}

utils.ends_with = function(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

utils.map = function(fn, tbl)
  local new = {}

  for _, v in ipairs(tbl) do
    table.insert(new, fn(v))
  end

  return new
end

return utils
