local M = {}

local wrappers = {
  ['"'] = { '"', '"' },
  ["'"] = { "'", "'" },
  ["("] = { "(", ")" },
  ["["] = { "[", "]" },
  ["{"] = { "{", "}" },
  ["<"] = { "<", ">" },
}

local function wrap_range(open, close, mode)
  local start_pos = vim.fn.getpos("'<")
  local end_pos   = vim.fn.getpos("'>")

  local bufnr = vim.api.nvim_get_current_buf()
  -- include end line, since get_lines excludes it
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_pos[2]-1, end_pos[2], false)

  if #lines == 0 then return end

  if mode == 'v' then
    local s_col = start_pos[3]
    local e_col = end_pos[3]

    local first = lines[1]
    local last  = lines[#lines]

    lines[1] = first:sub(1, s_col-1) .. open .. first:sub(s_col)
    if #lines == 1 then
      lines[1] = lines[1]:sub(1, e_col + #open) .. close .. lines[1]:sub(e_col + #open + 1)
    else
      lines[#lines] = last:sub(1, e_col) .. close .. last:sub(e_col+1)
    end

  elseif mode == 'V' then
    lines[1] = open .. lines[1]
    lines[#lines] = lines[#lines] .. close

  elseif mode == '\22' then
    for i, l in ipairs(lines) do
      lines[i] = open .. l .. close
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, start_pos[2]-1, end_pos[2], false, lines)
end

function M.setup()
  for key, pair in pairs(wrappers) do
    vim.keymap.set('x', key, function()
      local mode = vim.fn.mode()
      wrap_range(pair[1], pair[2], mode)
    end, { noremap = true, silent = true })
  end
end

return M

