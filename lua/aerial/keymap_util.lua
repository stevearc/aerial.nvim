local util = require("aerial.util")
local M = {}

local function resolve(action_module, rhs)
  if type(rhs) == "string" and vim.startswith(rhs, "actions.") then
    local mod = require(action_module)
    return resolve(action_module, mod[vim.split(rhs, ".", { plain = true })[2]])
  elseif type(rhs) == "table" then
    local opts = vim.deepcopy(rhs)
    opts.callback = nil
    return rhs.callback, opts
  end
  return rhs, {}
end

M.set_keymaps = function(mode, action_module, keymaps, bufnr, ...)
  local args = vim.F.pack_len(...)
  for k, v in pairs(keymaps) do
    local rhs, opts = resolve(action_module, v)
    if rhs then
      if type(rhs) == "function" and args.n > 0 then
        local _rhs = rhs
        rhs = function()
          _rhs(vim.F.unpack_len(args))
        end
      end
      vim.keymap.set(mode, k, rhs, { buffer = bufnr, nowait = true, desc = opts.desc })
    end
  end
end

M.show_help = function(action_module, keymaps)
  local actions_by_category = {}
  for key, action_name in pairs(keymaps) do
    if not action_name then
      goto continue
    end

    -- Resolve a name to an action
    local _, opts = resolve(action_module, action_name)

    -- Create entry for category if it doesn't exist
    local category = opts.category or "misc"
    if not actions_by_category[category] then
      actions_by_category[category] = {}
    end

    -- Add action to category
    if not actions_by_category[category][action_name] then
      local action_info = {
        category = category,
        desc = opts.desc or "",
        keys = {},
      }

      actions_by_category[category][action_name] = action_info
    end

    -- Map the key to the action
    table.insert(actions_by_category[category][action_name].keys, key)

    ::continue::
  end

  -- In case of multiple actions with the same key, we sort them alphabetically
  -- We sort in reverse order, as this makes all the `z` keymaps align nicely
  for _, actions in pairs(actions_by_category) do
    for _, action_info in pairs(actions) do
      table.sort(action_info.keys, function(a, b)
        return a > b
      end)
    end
  end

  -- Calculate max width of key combinations
  local max_key_width = 1
  for _, actions in pairs(actions_by_category) do
    for _, action_info in pairs(actions) do
      local keystr = table.concat(action_info.keys, "/")
      max_key_width = math.max(max_key_width, vim.api.nvim_strwidth(keystr))
    end
  end

  -- Create display lines
  local lines = {}
  local highlights = {}
  local max_line_width = 1

  for category, actions in pairs(actions_by_category) do
    if next(actions) == nil then
      goto continue
    end

    if #lines > 0 then
      table.insert(lines, "")
    end

    local header = " " .. category:upper()
    table.insert(lines, header)
    table.insert(highlights, { "Title", #lines, 1, #header + 1 })

    for action_name, action_info in pairs(actions) do
      local keystr = table.concat(action_info.keys, "/")
      local line = string.format("   %s   %s", util.rpad(keystr, max_key_width), action_info.desc)
      max_line_width = math.max(max_line_width, vim.api.nvim_strwidth(line))
      table.insert(lines, line)

      local start = 3
      for _, key in ipairs(action_info.keys) do
        local keywidth = vim.api.nvim_strwidth(key)
        table.insert(highlights, { "Special", #lines, start, start + keywidth })
        start = start + keywidth + 1
      end
    end

    ::continue::
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)

  local ns = vim.api.nvim_create_namespace("AerialKeymap")
  for _, hl in ipairs(highlights) do
    local hl_group, lnum, start_col, end_col = unpack(hl)
    local line_text = lines[lnum]
    if line_text and start_col < #line_text and end_col <= #line_text then
      vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, start_col, {
        end_col = end_col,
        hl_group = hl_group,
      })
    end
  end

  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = bufnr, nowait = true })
  vim.keymap.set("n", "<c-c>", "<cmd>close<CR>", { buffer = bufnr })
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].bufhidden = "wipe"

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight
  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = math.max(0, (editor_height - #lines) / 2),
    col = math.max(0, (editor_width - max_line_width - 1) / 2),
    width = math.min(editor_width, max_line_width + 1),
    height = math.min(editor_height, #lines),
    zindex = 150,
    style = "minimal",
    border = "rounded",
  })

  local function close()
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_win_close(winid, true)
    end
  end

  vim.api.nvim_create_autocmd("BufLeave", {
    callback = close,
    once = true,
    nested = true,
    buffer = bufnr,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    callback = close,
    once = true,
    nested = true,
  })
end

return M
