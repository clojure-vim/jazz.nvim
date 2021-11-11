local daedalus = require("daedalus")
local specs = require("daedalus.specs")
local impromptu = require("impromptu")

local clojars = {}

local client = daedalus.make_client(specs.define{
  ['*'] = {
    url = "https://clojars.org"
  },
  search = {
    path = "/search"
  }
})

clojars.deps = function(opt)
  local qs = {format = "json"}
  if opt.dep ~= nil then
    qs.q = opt.dep
  else
    -- TODO impement prompt
    return
  end
  local form = impromptu.filter{
    title = "🎵 Add :require dependency",
    options = {},
    handler = function(_, selected)
      tap(selected)
      -- TODO add to deps.edn/project.clj
      return true
    end
  }

  client.search{
    querystring = qs,
    handler = function(data)
      for _, item in ipairs(data.results) do
        local descr = item.group_name .. "/" .. item.jar_name .. ":" .. item.version
        if item.description ~= nil then
          descr = descr  .. "  " .. item.description
        end
        form:update{
          description = descr,
          item = item
        }
      end
    end
  }



end

return clojar

