local M = {}

local lua_pairs = pairs

local wrappers = {
  ['"']  = { '"', '"' },
  ["'"]  = { "'", "'" },
  ["("]  = { "(", ")" },
  ["["]  = { "[", "]" },
  ["{"]  = { "{", "}" },
  ["<"]  = { "<", ">" },
}

local function is_wrapped(str, open, close)
  return vim.startswith(str, open) and vim.endswith(str, close)
end

local function wrap_selection(open, close, mode)
  vim.cmd('normal! gv"zy')
  local text = vim.fn.getreg('z')

  local new
  if is_wrapped(text, open, close) then
    new = text:sub(#open + 1, #text - #close)
  else
    if mode == 'V' then -- visual line
      new = open .. text:gsub('\n$', '') .. close .. '\n'
    elseif mode == '\22' then -- visual block
      local lines = vim.split(text, '\n')
      for i, l in ipairs(lines) do
        lines[i] = open .. l .. close
      end
      new = table.concat(lines, '\n')
    else
      new = open .. text .. close
    end
  end

  vim.fn.setreg('z', new)
  vim.cmd('normal! gv"zp') -- replace selection
end

local function make_repeatable(fn)
  return function()
    fn()
    vim.fn['repeat#set']("gv", -1) -- make `.` reapply
  end
end

function M.setup()
  for key, pair in lua_pairs(wrappers) do
    vim.keymap.set('x', key, function()
      local mode = vim.fn.mode()
      wrap_selection(pair[1], pair[2], mode)
    end, { noremap = true, silent = true })
  end
end

return M

