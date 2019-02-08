-- luacheck: globals unpack vim
local impromptu = require("impromptu")
local connections = require('acid.connections')
local nrepl = require('acid.nrepl')
local acid_utils = require('acid.utils')

local find_value = function(tbl, val)
  for ix, v in ipairs(tbl) do
    if v == val then
      return ix
    end
  end
  return -1
end

local jazz_nrepl = {}

local select_portno = function(obj)
  return impromptu.new.form{
      title = "Select port number:",
      questions = {portno = {description = "Port number"}},
      handler = function(session, result)
        obj.port = tonumber(result.portno)

        session:pop()
        session.lines.port.description = "Port number (" .. result.portno .. ")"
        session.lines.port.hl = "String"
        return false
      end
  }
end

local connect_nrepl = function(obj)
  return impromptu.new.form{
      title = "Connect nrepl to:",
      questions = {
        portno = {description = "Port number"},
        host = {description = "Host address"}
      },
      handler = function(session, result)
        obj.port = tonumber(result.portno)
        obj.host = result.host
        obj.connect = true

        session:pop()

        session.lines.connect.description = "Connect to remote nrepl? (true)"
        session.lines.connect.hl = "String"

        session.lines.host.description = "Connect to address(" .. result.host .. ")"
        session.lines.host.hl = "String"

        session.lines.port.description = "Port number (" .. result.portno .. ")"
        session.lines.port.hl = "String"
        return false
      end
  }
end

local custom_nrepl = function(obj)
  local opts = {}
  local nrepl_config = {middlewares = nrepl.default_middlewares, pwd = obj.pwd}

  for k, _ in pairs(nrepl.middlewares) do
    opts[k] = {
      description = k,
      hl = "Comment"
    }
  end

  for _, k in ipairs(nrepl.default_middlewares) do
    opts[k].hl = "String"
  end

  opts.port = {
    description = "Port number (auto)",
    hl = "Comment"
  }

  --opts.bind = {
    --description = "Bind to address (127.0.0.1)",
    --hl = "Comment"
  --}

  --opts.host = {
    --description = "Connect to address (127.0.0.1)",
    --hl = "Comment"
  --}

  --opts.connect = {
    --description = "Connect to remote nrepl? (false)",
    --hl = "Comment"
  --}

  --opts.pwd = {
    --description = "Directory (" .. obj.pwd .. ")",
    --hl = "Comment"
  --}

  opts.start = {description = "Start with custom configuration"}
  opts.abort = {
    description = "Abort",
    key = "q"
  }


  return impromptu.new.ask{
    question = "Configure the custom nrepl:",
    quitable = false,
    options = opts,
    handler = function(session, selected)
      if selected.index == "start" then
        nrepl.start(nrepl_config)
        return true
      elseif selected.index == "port" then
        session:stack(select_portno(nrepl_config))
      elseif selected.index == "connect" then
        session:stack(connect_nrepl(nrepl_config))
      elseif selected.index == "abort" then
        session:pop()
      else
        local ix = find_value(nrepl_config.middlewares, selected.index)
        if ix == -1 then
          table.insert(nrepl_config.middlewares, selected.index)
          selected.hl = "String"
        else
          table.remove(nrepl_config.middlewares, ix)
          selected.hl = "Comment"
        end
      end
    end
  }
end

jazz_nrepl.nrepl_menu = function(pwd)
  pwd = pwd or vim.api.nvim_call_function("getcwd", {})
  if not acid_utils.ends_with(pwd, "/") then
    pwd = pwd .. "/"
  end

  local current = require('acid.connections').current[pwd]
  local opts = {}

  local check

  if current ~= nil then
    current = connections.store[current]
    check = function (v)
      return v[2] == current[2] and v[1] == current[1]
    end
  else
    check = function(_) return false end
  end

  for ix, v in ipairs(connections.store) do
    local opt = {}
    local str = "nrepl://" .. v[1] .. ":" .. v[2]

    if check(v) then
      opts.close = {
        description = "Close connection to " .. str ,
        hl = "Function"
      }

      opts.refresh = {
        description = "Refresh connections",
        hl = "Function"
      }

      str = str .. " (current)"
      opt.hl = "String"
    end

    opt.description = str
    opts[ix] = opt
  end

  opts.new = {
    description = "Spawn new nrepl",
    hl = "Function"
  }

  opts.custom = {
    description = "Spawn custom nrepl",
    hl = "Function"
  }

  impromptu.ask{
    question = "Select nrepl to connect to:",
    options = opts,
    handler = function(session, selected)
      if selected.index == "new" then
        nrepl.start{pwd = pwd}
      elseif selected.index == "close" then
        nrepl.stop{pwd = pwd}
      elseif selected.index == "refresh" then
        nrepl.stop{pwd = pwd}
        nrepl.start{pwd = pwd}
      elseif selected.index ==  "custom" then
        session:stack(custom_nrepl{pwd = pwd})
        return false
      else
        connections:select(pwd, selected)
      end
      return true
    end
  }
end

vim.api.nvim_command("command! -nargs=0 JazzNrepl lua require('jazz.nrepl').nrepl_menu()")

return jazz_nrepl