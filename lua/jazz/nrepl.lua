-- luacheck: globals unpack vim
local impromptu = require("impromptu")
local connections = require('acid.connections')
local nrepl = require('acid.nrepl')
local acid_utils = require('acid.utils')
local acid = require('acid')
local ops = require('acid.ops')
local os = require('os')

local empty = function(coll)
  local ret = true
  for _, _ in pairs(coll) do
    ret = false
    break
  end
  for _, _ in ipairs(coll) do
    ret = false
    break
  end

  return ret
end

local read_aliases = function(fname, handler)
  if vim.fn.filereadable(fname) == 1 then
    acid.run(ops.eval{code = '(run! println (keys (:aliases (read-string (slurp "' .. fname .. '")))))'}:with_handler(function(obj)
      if obj.out ~= nil then
        local out = vim.trim(obj.out)
        handler(out)
      elseif obj.err ~= nil or obj.ex ~= nil then
        vim.api.nvim_err_writeln(obj.err or obj.ex)
      end
      end), acid.admin_session())
    end
end

local jazz_nrepl = {}

-- nrepl option support:
--port = select_portno
--middlewares = configure_middlewares
--alias = parse_aliases
--bind = not supported
--deps_file = not supported
--skip_autocmd = not supported
--disable_output_capture = not supported

local select_portno = function(inner_handler)
  return impromptu.new.form{
      title = "🎵 Select port number:",
      questions = {portno = {description = "Port number"}},
      handler = function(session, result)
        return inner_handler(session, result)
      end
  }
end

local existing = function(obj)
  local opts = {}
  for ix, v in pairs(connections.store) do
    if #v == 2 then
      local opt = {}
      local str = "nrepl://" .. v[1] .. ":" .. v[2]
      opt.description = str
      opt.index = ix
      opts[ix] = opt
    end
  end
  tap{(not empty(opts)), opts}
  if not empty(opts) then
    opts.new = {
      description = "Connect to other existing nREPL",
      hl = "Function"
    }
    opts.abort = {
      description = "Cancel",
      key = "q",
      hl = "Character"
    }
    return impromptu.new.ask{
      title = "🎵 Select nrepl to connect to:",
      quitable = false,
      options = opts,
      handler = function(session, selected)
        local ix = selected.index
        if ix == "new" then
          session:stack(select_portno(function(ss, result)
            if result.portno ~= "" then
              connections.select(obj.pwd, connections.add{"127.0.0.1", tonumber(result.portno)})
              return true
            else
              ss:pop()
              return false
            end
          end))
        elseif ix == "abort" then
          session:pop()
        else
          connections.select(obj.pwd, ix)
        end
      end
    }
  else
    return select_portno(function(_, result)
      if result.portno ~= "" then
        connections.select(obj.pwd, connections.add{"127.0.0.1", tonumber(result.portno)})
      end
      return true
    end)
  end

end

local parse_aliases = function(obj, file)
  local aliases = {}
  local session = obj.session
  local conn = acid.admin_session()

  local opts = {
    confirm = {
      description = "Confirm",
      key = "c",
      hl = "String"
    },
    abort = {
      description = "Cancel",
      key = "q",
      hl = "Character"
    }
  }

  for _, v in ipairs(obj.alias or {}) do
    aliases[v] = true
    opts[v] = {description = v, hl = "Function"}
  end

  local menu = impromptu.new.ask{
      title = "🎵 Select aliases",
      quitable = false,
      options = opts,
      handler = function(session, selected)
        local ix = selected.index

        if ix == "confirm" then
          local selected = {}
          for k, v in pairs(aliases) do
            if v then
              table.insert(selected, k)
            end
          end
          obj.alias = selected
          session:pop()
        elseif ix == "abort" then
          session:pop()
        else
          local toggle = not (aliases[ix] or false)
          aliases[ix] = toggle
          if toggle then
           session.lines[ix].hl = "Function"
         else
           session.lines[ix].hl = "Comment"
         end
        end
        return false
      end
  }

  local main_config = os.getenv('HOME') .. "/.clojure/deps.edn"
  local update_menu = function(out)
    if menu.lines[out] == nil then
      menu.lines[out] = {description = out, hl = "Comment"}
      session:render()
    end
  end
  read_aliases(main_config, update_menu)
  read_aliases(file, update_menu)
  return menu
end

local configure_middlewares = function(obj)
  local opts = {
        confirm = {
          description = "Confirm",
          key = "c",
          hl = "String"
        },
        abort = {
          description = "Cancel",
          key = "q",
          hl = "Character"
        }
  }
  local middlewares = {}
  for k, _ in pairs(nrepl.middlewares) do
    opts[k] = {
      description = k,
      hl = "Comment"
    }
  end
  for _, k in ipairs(obj.middlewares or nrepl.default_middlewares) do
    opts[k].hl = "Function"
    middlewares[k] = true
  end

  return impromptu.new.ask{
      title = "🎵 Select Middlewares",
      quitable = false,
      options = opts,
      handler = function(session, selected)
        local ix = selected.index
        if ix == "confirm" then
          local selected = {}
          for k, v in pairs(middlewares) do
            if v then
              table.insert(selected, k)
            end
          end
          obj.middlewares = selected
          obj.session:pop()
        elseif ix == "abort" then
          obj.session:pop()
        else
          local toggle = not (middlewares[ix] or false)
          middlewares[ix] = toggle
          if toggle then
           session.lines[ix].hl = "Function"
           else
             session.lines[ix].hl = "Comment"
           end
        end
        return false
    end
  }
end

local custom_nrepl = function(obj)
  local opts = {}

  opts.port = {
    description = "Configure Port Number",
    hl = "Conditional"
  }

  opts.middlewares = {
    description = "Configure Middlewares",
    hl = "Conditional"
  }

  opts.aliases = {
    description = "Configure Aliases",
    hl = "Conditional"
  }

  opts.existing = {
    description = "Connect to existing nREPL",
    hl = "Function"
  }

  opts.start = {
    description = "Start new nREPL",
    hl = "Character"
  }
  return impromptu.new.ask{
    title = "🎵 Configure the nREPL:",
    options = opts,
    handler = function(session, selected)
      if selected.index == "start" then
        nrepl.start(obj)
        return true
      elseif selected.index == "port" then
        session:stack(select_portno(function(ss, result)
          ss:pop()
          if result.portno ~= "" then
            obj.port = result.portno
            ss.lines.port.description = "Configure Port Number [" .. result.portno .. "]"
            ss.lines.port.hl = "Function"
          else
            obj.port = nil
            ss.lines.port.description = "Configure Port Number"
            ss.lines.port.hl = "Conditional"
          end
        end))
      elseif selected.index == "existing" then
        session:stack(existing(obj))
      elseif selected.index == "middlewares" then
        session:stack(configure_middlewares(obj))
      elseif selected.index == "aliases" then
        session:stack(parse_aliases(obj, obj.pwd .."/deps.edn"))
      end
    end
  }
end

jazz_nrepl.nrepl_menu = function(pwd)
  pwd = pwd or vim.fn.getcwd()
  if not acid_utils.ends_with(pwd, "/") then
    pwd = pwd .. "/"
  end
  local session = impromptu.session()

  session:stack(custom_nrepl{
    pwd = pwd,
    session = session,
    alias = {},
    middlewares = nrepl.default_middlewares
  }):render()
end

return jazz_nrepl
