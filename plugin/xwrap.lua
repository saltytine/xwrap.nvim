local M = {}

function M.setup()
  local map = vim.keymap.set

  map('v', '"',  'c"<C-r>""<Esc>', { noremap = true, silent = true })
  map('v', "'",  "c'<C-r>\"'<Esc>", { noremap = true, silent = true })
  map('v', '(',  'c(<C-r>")<Esc>', { noremap = true, silent = true })
  map('v', '[',  'c[<C-r>"]<Esc>', { noremap = true, silent = true })
  map('v', '{',  'c{<C-r>"}<Esc>', { noremap = true, silent = true })
  map('v', '<lt>', 'c<<C-r>"><Esc>', { noremap = true, silent = true })
end

return M
