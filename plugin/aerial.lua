-- Has set up check
local aerial_loaded = vim.g.aerial_loaded
if aerial_loaded and aerial_loaded ~= 0 then
  return
end
vim.g.aerial_loaded = true

-- Minimal compatible version check
if vim.fn.has("nvim-0.8") == 0 then
  vim.notify_once(
    "aerial is deprecated for Neovim <0.8. Please use the nvim-0.5 branch or upgrade Neovim",
    vim.log.levels.ERROR
  )
  return
end

local function list_complete(choices)
  return function(arg)
    return vim.tbl_filter(function(dir)
      return vim.startswith(dir, arg)
    end, choices)
  end
end

local commands = {
  {
    cmd = "AerialToggle",
    args = "`left/right/float`",
    func = function(params)
      local direction
      if params.args ~= "" then
        direction = params.args
      end
      require("aerial").toggle({
        focus = not params.bang,
        direction = direction,
      })
    end,
    funcDesc = "toggle",
    defn = {
      desc = "Open or close the aerial window. With `!` cursor stays in current window",
      nargs = "?",
      bang = true,
      complete = list_complete({ "left", "right", "float" }),
    },
  },
  {
    cmd = "AerialOpen",
    args = "`left/right/float`",
    func = function(params)
      local direction
      if params.args ~= "" then
        direction = params.args
      end
      require("aerial").open({
        focus = not params.bang,
        direction = direction,
      })
    end,
    funcDesc = "open",
    defn = {
      desc = "Open the aerial window. With `!` cursor stays in current window",
      nargs = "?",
      bang = true,
      complete = list_complete({ "left", "right", "float" }),
    },
  },
  {
    cmd = "AerialOpenAll",
    func = function()
      require("aerial").open_all()
    end,
    funcDesc = "openAll",
    defn = {
      desc = "Open an aerial window for each visible window.",
    },
  },
  {
    cmd = "AerialClose",
    func = function()
      require("aerial").close()
    end,
    funcDesc = "close",
    defn = {
      desc = "Close the aerial window.",
    },
  },
  {
    cmd = "AerialCloseAll",
    func = function()
      require("aerial").close_all()
    end,
    funcDesc = "closeAll",
    defn = {
      desc = "Close all visible aerial windows.",
    },
  },
  {
    cmd = "AerialNext",
    func = function(params)
      require("aerial").next(params.count)
    end,
    funcDesc = "next",
    defn = {
      desc = "Jump forwards {count} symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialPrev",
    func = function(params)
      require("aerial").prev(params.count)
    end,
    funcDesc = "prev",
    defn = {
      desc = "Jump backwards [count] symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialGo",
    func = function(params)
      local opts = {
        jump = not params.bang,
        index = params.count,
        split = params.args,
      }
      require("aerial").select(opts)
    end,
    funcDesc = "go",
    defn = {
      desc = "Jump to the [count] symbol (default 1).",
      count = 1,
      bang = true,
      nargs = "?",
    },
    long_desc =
    'If with [!] and inside aerial window, the cursor will stay in the aerial window. [split] can be "v" to open a new vertical split, or "h" to open a horizontal split. [split] can also be a raw vim command, such as "belowright split". This command respects |switchbuf|=uselast',
  },
  {
    cmd = "AerialInfo",
    func = function()
      local data = require("aerial").info()
      print("Aerial Info")
      print("-----------")
      print(string.format("Filetype: %s", data.filetype))
      if data.ignore.ignored then
        print(
          string.format(
            "Aerial ignores this window: %s. See the 'ignore' config in :help aerial-options",
            data.ignore.message
          )
        )
      end
      print("Configured backends:")
      for _, status in ipairs(data.backends) do
        local line = "  " .. status.name
        if status.supported then
          line = line .. " (supported)"
        else
          line = line .. " (not supported) [" .. status.error .. "]"
        end
        if status.attached then
          line = line .. " (attached)"
        end
        print(line)
      end
      print(string.format("Show symbols: %s", data.filter_kind_map))
    end,
    funcDesc = "info",
    defn = {
      desc = "Print out debug info related to aerial.",
    },
  },
  {
    cmd = "AerialNavToggle",
    func = function()
      require("aerial.nav_view").toggle()
    end,
    funcDesc = "navToggle",
    defn = {
      desc = "Open or close the aerial nav window.",
    },
  },
  {
    cmd = "AerialNavOpen",
    func = function()
      require("aerial.nav_view").open()
    end,
    funcDesc = "navOpen",
    defn = {
      desc = "Open the aerial nav window.",
    },
  },
  {
    cmd = "AerialNavClose",
    func = function()
      require("aerial.nav_view").close()
    end,
    funcDesc = "navClose",
    defn = {
      desc = "Close the aerial nav window.",
    },
  },
}

local function create_commands()
  for _, definition in pairs(commands) do
    vim.api.nvim_create_user_command(definition.cmd, definition.func, definition.defn)
  end
end

local function create_autocmds()
  local group = vim.api.nvim_create_augroup("AerialSetup", { clear = true })
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    desc = "Aerial update windows and attach backends",
    pattern = "*",
    group = group,
    callback = function()
      require("aerial.autocommands").on_enter_buffer()
    end,
  })
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Aerial mark LSP backend as available",
    pattern = "*",
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      require("aerial.backends.lsp").on_attach(client, args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("LspDetach", {
    desc = "Aerial mark LSP backend as unavailable",
    pattern = "*",
    group = group,
    callback = function(args)
      require("aerial.backends.lsp").on_detach(args.data.client_id, args.buf)
    end,
  })
end

local map_pydefn = function(tbl)
  tbl = tbl or {}
  return {
    desc = tbl.desc,
    count = tbl.count,
    nargs = tbl.nargs,
    bang = tbl.bang,
  }
end

local map_pydoc = function(tbl)
  local copy = {}

  for key, value in pairs(tbl) do
    copy[key] = {
      cmd = value.cmd,
      defn = map_pydefn(value["defn"]),
      func = value.funcDesc,
      args = value.args,
      deprecated = value.deprecated,
      long_desc = value.long_desc,
    }
  end

  return copy
end

if vim.g.aerial_echo_commands_on_load then
  print(vim.json.encode(map_pydoc(commands)))
end

create_commands()
create_autocmds()
