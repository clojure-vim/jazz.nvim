local utils = {}

utils.ends_with = function(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

return utils
