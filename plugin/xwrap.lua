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
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_row, start_col = start_pos[2]-1, start_pos[3]-1
  local end_row, end_col = end_pos[2]-1, end_pos[3]

  if end_row < start_row or (end_row == start_row and end_col < start_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
  return table.concat(lines, "\n"), {start_row, start_col, end_row, end_col}
end

local function set_visual_selection(new_text, range)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_text(bufnr, range[1], range[2], range[3], range[4], vim.split(new_text, "\n"))
end

local function toggle_wrap(key)
  local pair = M.pairs[key]
  if not pair then return end
  local left, right = pair[1], pair[2]

  local text, range = get_visual_selection()
  if not text then return end

  local new_text
  if vim.startswith(text, left) and vim.endswith(text, right) then
    new_text = text:sub(#left+1, -#right-1)
    M.last_action = { action="unwrap", key=key }
  else
    new_text = left .. text .. right
    M.last_action = { action="wrap", key=key }
  end

  set_visual_selection(new_text, range)
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
    if la.action then
      vim.cmd("normal! gv")
      toggle_wrap(la.key)
    else
      vim.cmd("normal! .")
    end
  end, { silent = true })
end

return M
