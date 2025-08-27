local M = {}

local function wrap_range(open, close)
  local start_pos = vim.fn.getpos("'<")
  local end_pos   = vim.fn.getpos("'>")

  local s_row, s_col = start_pos[2]-1, start_pos[3]-1
  local e_row, e_col = end_pos[2]-1, end_pos[3]

  local bufnr = vim.api.nvim_get_current_buf()
  local text = vim.api.nvim_buf_get_text(bufnr, s_row, s_col, e_row, e_col, {})
  if #text == 0 then return end

  local flat = table.concat(text, "\n")

  -- unwrap if already wrapped
  if vim.startswith(flat, open) and vim.endswith(flat, close) then
    flat = flat:sub(#open+1, #flat-#close)
  else
    flat = open .. flat .. close
  end

  local new_lines = vim.split(flat, "\n", { plain = true })
  vim.api.nvim_buf_set_text(bufnr, s_row, s_col, e_row, e_col, new_lines)
end

local pairs_map = {
  ["'"] = { "'", "'" },
  ['"'] = { '"', '"' },
  ["("] = { "(", ")" },
  ["["] = { "[", "]" },
  ["{"] = { "{", "}" },
  ["<"] = { "<", ">" },
  ["*"] = { "*", "*" },
  ["_"] = { "_", "_" },
  ["`"] = { "`", "`" },
}

function M.setup()
  for key, pair in pairs(pairs_map) do
    vim.keymap.set("x", key, function()
      wrap_range(pair[1], pair[2])
    end, { silent = true })
  end
end

return M

