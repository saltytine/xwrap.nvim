local M = {}

M.pairs = {
  ['"']  = { '"', '"' },
  ["'"]  = { "'", "'" },
  ["("]  = { "(", ")" },
  ["["]  = { "[", "]" },
  ["{"]  = { "{", "}" },
  ["<"]  = { "<", ">" },
}

M.last_action = nil

local function get_visual_selection()
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))
  if ls ~= le then return nil end

  local line = vim.fn.getline(ls)
  return line:sub(cs, ce)
end

local function set_visual_selection(replacement)
  vim.cmd('normal! gv"_c')
  vim.api.nvim_paste(replacement, true, -1)
end

local function toggle_wrap(key)
  local pair = M.pairs[key]
  if not pair then return end
  local left, right = pair[1], pair[2]

  local text = get_visual_selection()
  if not text then return end

  if text:sub(1, #left) == left and text:sub(-#right) == right then
    local unwrapped = text:sub(#left+1, -#right-1)
    set_visual_selection(unwrapped)
    M.last_action = { action="unwrap", key=key }
  else
    local wrapped = left .. text .. right
    set_visual_selection(wrapped)
    M.last_action = { action="wrap", key=key }
  end
end

function M.setup(opts)
  opts = opts or {}
  if opts.pairs then
    M.pairs = opts.pairs
  end

  for key, _ in pairs(M.pairs) do
    vim.keymap.set("v", key, function()
      toggle_wrap(key)
    end, { silent = true, desc = "Toggle wrap with " .. key })
  end

  vim.keymap.set("n", ".", function()
    if not M.last_action then
      return vim.cmd("normal! .")
    end
    local la = M.last_action
    if la.action == "wrap" or la.action == "unwrap" then
      vim.cmd("normal! gv")
      toggle_wrap(la.key)
    else
      vim.cmd("normal! .")
    end
  end, { silent = true })
end

return M
