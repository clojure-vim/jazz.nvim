-- luacheck: globals vim
local acid = require("acid")
local utils = require("jazz.utils")
local log = require("jazz.log").msg
local interrupt_op = require("acid.ops").interrupt
local connections = require("acid.connections")
local sessions = require("acid.sessions")
local impromptu = require("impromptu")

local interrupt = {}


interrupt.select_session = function()
  local connection_ix = connections.peek()
  local session_ids = sessions.store[connection_ix]
  if session_ids ~= nil then
    session_ids = session_ids.list
  else
    return
  end

  local response = function(data)
    if utils.contains('interrupted', data.status) then
      log"Successfully interrupted session"
    elseif utils.contains('session-idle', data.status) then
      log"Nothing to interrupt"
    else
      log"shrug" -- TODO deal with other two cases
    end
  end

  if #session_ids > 1 then

    impromptu.filter{
      title = "🎵 Select session for interrupting",
      options = utils.map(function(id)
        return {description = id}
      end, session_ids),
    handler = function(_, selected)
      acid.run(interrupt_op{session = selected.description}:with_handler(response))
      return true
    end
    }
  else
    acid.run(interrupt_op{session = session_ids[1]}:with_handler(response))
  end

end

return interrupt
