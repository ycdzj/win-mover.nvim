local M = {}

function M.reverse_list(list)
  local reversed = {}
  for i = #list, 1, -1 do
    table.insert(reversed, list[i])
  end
  return reversed
end

function M.shallow_copy(orig)
  local copy = {}
  for k, v in pairs(orig) do
    copy[k] = v
  end
  return copy
end

function M.shallow_compare(t1, t2)
  for k, v in pairs(t1) do
    if t2[k] ~= v then
      return false
    end
  end
  for k, v in pairs(t2) do
    if t1[k] ~= v then
      return false
    end
  end
  return true
end

function M.getchar()
  local char = vim.fn.getchar()
  if type(char) == 'number' then
    char = vim.fn.nr2char(char)
  end
  return char
end

function M.merge_table(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == 'table' and type(t1[k]) == 'table' then
      M.merge_table(t1[k], v)
    else
      t1[k] = v
    end
  end
end

return M
