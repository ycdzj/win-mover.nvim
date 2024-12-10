local utils = require('win-mover.utils')

local M = {}

M.Node = {}
M.Node.__index = M.Node

function M.Node:new(properties, children)
  local node = setmetatable({
    parent = nil,
    children = {},
    prop = properties or {},
  }, self)
  node:add_children(children or {})
  return node
end

function M.Node:index()
  for i, cur_child in ipairs(self.parent.children) do
    if cur_child == self then
      return i
    end
  end
  assert(false, 'Parent should contain the child')
end

function M.Node:remove_child(child)
  local index = child:index()
  child.parent = nil
  table.remove(self.children, index)
end

function M.Node:add_child(child, index)
  if child.parent then
    child.parent:remove_child(child)
  end
  child.parent = self
  if index then
    table.insert(self.children, index, child)
  else
    table.insert(self.children, child)
  end
end

function M.Node:add_children(children)
  children = utils.shallow_copy(children)
  for _, child in ipairs(children) do
    self:add_child(child)
  end
end

function M.Node:clear_children()
  while #self.children > 0 do
    self:remove_child(self.children[#self.children])
  end
end

function M.Node:reverse_children()
  self.children = utils.reverse_list(self.children)
end

function M.Node:prev()
  local index = self:index()
  return self.parent.children[index - 1]
end

function M.Node:next()
  local index = self:index()
  return self.parent.children[index + 1]
end

function M.search_win(root, win_id)
  for _, child in ipairs(root.children) do
    local node = M.search_win(child, win_id)
    if node then
      return node
    end
  end
  if root.prop.win_id == win_id then
    return root
  end
  return nil
end

function M.reverse_diagonal(root)
  root.prop.row = not root.prop.row
  for _, child in ipairs(root.children) do
    M.reverse_diagonal(child)
  end
end

function M.reverse_horizontal(root)
  if root.prop.row then
    root:reverse_children()
  end
  for _, child in ipairs(root.children) do
    M.reverse_horizontal(child)
  end
end

function M.identical(root1, root2)
  if not utils.shallow_compare(root1.prop, root2.prop) then
    return false
  end
  if #root1.children ~= #root2.children then
    return false
  end
  for i, _ in ipairs(root1.children) do
    if not M.identical(root1.children[i], root2.children[i]) then
      return false
    end
  end
  return true
end

function M.build_from_layout(layout)
  if layout[1] == 'leaf' then
    return M.Node:new({ row = false, win_id = layout[2] })
  end

  local root = M.Node:new({ row = layout[1] == 'row' })
  for _, sub_layout in ipairs(layout[2]) do
    root:add_child(M.build_from_layout(sub_layout))
  end
  return root
end

return M
