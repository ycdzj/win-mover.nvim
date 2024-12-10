local tree = require('win-mover.tree')

local M = {}

M.updater = {
  adj = function(root, node)
    local parent = node.parent
    if parent == nil then
      return root
    end

    if parent.prop.row then
      local prev = node:prev()
      if prev then
        local index = prev:index()
        local col_node = tree.Node:new({ row = false }, { node, prev })
        parent:add_child(col_node, index)
        return root
      end
    end

    if not parent.prop.row then
      local next = node:next()
      if next then
        local index = node:index()
        local row_node = tree.Node:new({ row = true }, { node, next })
        parent:add_child(row_node, index)
        return root
      end
    end

    local cur = node.parent
    while cur.parent and not cur.parent.prop.row do
      cur = cur.parent
    end

    if cur.parent then
      cur.parent:add_child(node, cur:index())
      return root
    end

    return tree.Node:new({ row = true }, { node, cur })
  end,

  far = function(root, node)
    return tree.Node:new({ row = true }, { node, root })
  end
}

M.reverse = {
  left = { diagonal = false, horizontal = false },
  right = { diagonal = false, horizontal = true },
  up = { diagonal = true, horizontal = false },
  down = { diagonal = true, horizontal = true },
}

function M.move(root, node, updater, reverse)
  assert(not root.parent, 'root should not have parent')

  if reverse.diagonal then tree.reverse_diagonal(root) end
  if reverse.horizontal then tree.reverse_horizontal(root) end

  root = updater(root, node)

  if reverse.horizontal then tree.reverse_horizontal(root) end
  if reverse.diagonal then tree.reverse_diagonal(root) end

  return root
end

return M
