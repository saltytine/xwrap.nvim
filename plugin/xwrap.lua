local M = {}

local pairs = {
  ['"'] = '"',
  ["'"] = "'",
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ["<"] = ">"
}

function M.wrap(type, char)
  local opener = char
  local closer = pairs[char]
  if not closer then return end

  local sel = ""
  if type == "v" then -- characterwise visual
    vim.cmd('normal! `[v`]y')
    sel = vim.fn.getreg('"')
    if sel:sub(1,1) == opener and sel:sub(-1) == closer then
      sel = sel:sub(2, -2) -- unwrap
    else
      sel = opener .. sel .. closer
    end
    vim.fn.setreg('"', sel)
    vim.cmd('normal! gv"0p')
  elseif type == "V" then -- linewise visual
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    for l = start_line, end_line do
      local line = vim.fn.getline(l)
      if line:sub(1,1) == opener and line:sub(-1) == closer then
        vim.fn.setline(l, line:sub(2, -2))
      else
        vim.fn.setline(l, opener .. line .. closer)
      end
    end
  elseif type == "\022" then -- blockwise visual (<C-v>)
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    for l = start_line, end_line do
      local line = vim.fn.getline(l)
      local s = vim.fn.col("'<")
      local e = vim.fn.col("'>")
      local chunk = line:sub(s, e)
      if chunk:sub(1,1) == opener and chunk:sub(-1) == closer then
        chunk = chunk:sub(2, -2)
      else
        chunk = opener .. chunk .. closer
      end
      vim.fn.setline(l, line:sub(1, s-1) .. chunk .. line:sub(e+1))
    end
  end
end

local function make_mapping(char)
  return function()
    vim.go.operatorfunc = "v:lua.require'wrap'.wrap"
    vim.fn.feedkeys("g@" .. char, "n") -- makes it repeatable
  end
end

function M.setup()
  for c, _ in pairs(pairs) do
    vim.keymap.set("v", c, function()
      local mode = vim.fn.mode()
      M.wrap(mode, c)
      vim.fn['repeat#set'](string.format(":'<,'>lua require'wrap'.wrap('%s','%s')<CR>", mode, c))
    end, { noremap = true, silent = true })
  end
end

return M

