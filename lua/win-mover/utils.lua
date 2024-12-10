local M = {}

function M.reverse_list(list)
  local reversed = {}
  for i = #list, 1, -1 do
    table.insert(reversed, list[i])
  end
  return reversed
end

function M.getchar()
  local char = vim.fn.getchar()
  if type(char) == 'number' then
    char = vim.fn.nr2char(char)
  end
  return char
end

return M
