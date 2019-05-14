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

utils.iter_map = function(fn, iter, c, zero)
  return function(inv, cc)
    local ix, value = iter(inv, cc)
    return ix, fn(value)
  end, c, zero
end

utils.contains = function(item, iter)
  for _, v in ipairs(iter) do
    if v == item then
      return true
    end
  end
  return false
end

return utils
