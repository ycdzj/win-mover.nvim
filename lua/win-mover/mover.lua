local tree = require('win-mover.tree')

local M = {}

M.updater = {
  adj = function(root, node)
    local parent = node.parent
    if parent == nil then
      return root
    end

    local prev = node:prev()
    if parent.prop.vertical and prev then
      if #parent.children > 2 then
        local prev_index = prev:index()
        local col_node = tree.Node:new({ vertical = false }, { node, prev })
        parent:add_child(col_node, prev_index)
      else
        parent:add_child(prev)
      end
      return root
    end

    local cur = node.parent
    while cur.parent and not cur.parent.prop.vertical do
      cur = cur.parent
    end

    if cur.parent then
      cur.parent:add_child(node, cur:index())
      return root
    end

    return tree.Node:new({ vertical = true }, { node, cur })
  end,

  far = function(root, node)
    return tree.Node:new({ vertical = true }, { node, root })
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
