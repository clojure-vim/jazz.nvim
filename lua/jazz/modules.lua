-- luacheck: globals vim
-- TODO Add optional alias
local acid = require("acid")
local ops = require("acid.ops")
local impromptu = require("impromptu")
local features = require("acid.features")

local modules = {}

modules.get_alias_for_ns = function(ns, handler)

  acid.run(ops['namespace-aliases']{
        ['serialization-format'] = 'bencode'
    }:with_handler(
      function(data)
        -- TODO Handle clojurescript
        local alias_map = data['namespace-aliases'].clj
        local the_alias

        for alias, nss in pairs(alias_map) do
          for _, namespace in ipairs(nss) do

            local updated_ns = namespace:gsub("/", ".")

            tap{namespace, ns, updated_ns, alias}


            if updated_ns == ns then
              the_alias = alias
              break
            end
          end

          if the_alias ~= nil then
            break
          end
        end

        handler(the_alias)
        return
      end
    ))

end

modules.select_add_require = function()

  local winnr = vim.api.nvim_get_current_win()

  local filter = impromptu.filter{
    title = "🎵 Add :require dependency",
    options = {},
    handler = function(_, selected)
      modules.get_alias_for_ns(selected.namespace, function(alias)

        local namespace = selected.namespace
        if alias ~= nil then
          namespace = namespace .. " :as " .. alias
        end
        vim.api.nvim_set_current_win(winnr)
        features.add_require("[" .. namespace .. "]")
        end)
      return true
    end
  }

  acid.run(ops['ns-list']{}:with_handler(function(ret)
    for _, namespace in ipairs(ret['ns-list']) do
        filter:update{
          description = "[" .. namespace .. "]",
          namespace = namespace
        }
      end

  end))

end

return modules
