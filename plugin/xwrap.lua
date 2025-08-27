-- local M = {}
--
-- function M.setup()
--   local map = vim.keymap.set
--
--   map('v', '"',  'c"<C-r>""<Esc>', { noremap = true, silent = true })
--   map('v', "'",  "c'<C-r>\"'<Esc>", { noremap = true, silent = true })
--   map('v', '(',  'c(<C-r>")<Esc>', { noremap = true, silent = true })
--   map('v', '[',  'c[<C-r>"]<Esc>', { noremap = true, silent = true })
--   map('v', '{',  'c{<C-r>"}<Esc>', { noremap = true, silent = true })
--   map('v', '<lt>', 'c<<C-r>"><Esc>', { noremap = true, silent = true })
-- end
--
-- return M

local M = {}

local pairs = {
  ['"'] = '"',
  ["'"] = "'",
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ["<"] = ">",
}

-- get selected text
local function get_visual_selection()
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))
  local lines = vim.api.nvim_buf_get_lines(0, ls-1, le, false)
  if #lines == 0 then return "", ls, cs, le, ce end
  lines[1] = string.sub(lines[1], cs, -1)
  lines[#lines] = string.sub(lines[#lines], 1, ce)
  return table.concat(lines, "\n"), ls, cs, le, ce
end

local function wrap_or_unwrap(delim)
  local closing = pairs[delim]
  if not closing then return end

  local text, ls, cs, le, ce = get_visual_selection()
  if text == "" then return end

  local first, last = text:sub(1,1), text:sub(-1)
  local new
  if first == delim and last == closing then
    new = text:sub(2, #text-1) -- unwrap
  else
    new = delim .. text .. closing -- wrap
  end

  -- replace selection
  vim.api.nvim_buf_set_text(0, ls-1, cs-1, le-1, ce, vim.split(new, "\n"))
end

function M.setup()
  for open, _ in pairs(pairs) do
    vim.keymap.set("v", open, function() wrap_or_unwrap(open) end, { silent = true })
  end
end

return M
