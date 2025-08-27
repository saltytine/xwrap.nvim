local M = {}

local wrappers = {
  ['"']  = { '"', '"' },
  ["'"]  = { "'", "'" },
  ["("]  = { "(", ")" },
  ["["]  = { "[", "]" },
  ["{"]  = { "{", "}" },
  ["<"]  = { "<", ">" },
}

local function is_wrapped(line, open, close)
  return vim.startswith(line, open) and vim.endswith(line, close)
end

local function wrap_range(open, close, mode)
  local start_pos = vim.fn.getpos("'<")
  local end_pos   = vim.fn.getpos("'>")

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_pos[2]-1, end_pos[2], false)

  if mode == 'v' then
    local s_col = start_pos[3]
    local e_col = end_pos[3]

    local first = lines[1]
    local last  = lines[#lines]

    lines[1] = first:sub(1, s_col-1) .. open .. first:sub(s_col)
    lines[#lines] = lines[#lines]:sub(1, e_col) .. close .. last:sub(e_col+1)

  elseif mode == 'V' then
    lines[1] = open .. lines[1]
    lines[#lines] = lines[#lines] .. close

  elseif mode == '\22' then
    for i,l in ipairs(lines) do
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

