-- xwrap.lua
local M = {}

local function toggle_wrap(open, close)
  local s_start = vim.fn.getpos("'<")
  local s_end   = vim.fn.getpos("'>")

  local lines = vim.fn.getline(s_start[2], s_end[2])
  if #lines == 0 then return end

  if #lines == 1 then
    local text = lines[1]:sub(s_start[3], s_end[3])
    if text:sub(1,1) == open and text:sub(-1) == close then
      text = text:sub(2, -2)
    else
      text = open .. text .. close
    end
    local line = lines[1]
    lines[1] = line:sub(1, s_start[3]-1) .. text .. line:sub(s_end[3]+1)
  else
    lines[1] = lines[1]:sub(1, s_start[3]-1) .. open .. lines[1]:sub(s_start[3])
    lines[#lines] = lines[#lines]:sub(1, s_end[3]) .. close .. lines[#lines]:sub(s_end[3]+1)
  end

  vim.fn.setline(s_start[2], lines)
end

function M.setup()
  local map = vim.keymap.set
  map("v", '"',  function() toggle_wrap('"', '"') end, { desc = "Toggle wrap with \"" })
  map("v", "'",  function() toggle_wrap("'", "'") end, { desc = "Toggle wrap with '" })
  map("v", "(",  function() toggle_wrap("(", ")") end, { desc = "Toggle wrap with ()" })
  map("v", "[",  function() toggle_wrap("[", "]") end, { desc = "Toggle wrap with []" })
  map("v", "{",  function() toggle_wrap("{", "}") end, { desc = "Toggle wrap with {}" })
  map("v", "<",  function() toggle_wrap("<", ">") end, { desc = "Toggle wrap with <>" })
end

return M

