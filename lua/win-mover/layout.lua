local config = require('win-mover.config')
local tree = require('win-mover.tree')

local M = {}

local directions = {
  left = { diagonal = false, horizontal = false },
  right = { diagonal = false, horizontal = true },
  up = { diagonal = true, horizontal = false },
  down = { diagonal = true, horizontal = true },
}

local function normalize(root)
  local children = vim.tbl_extend('force', {}, root.children)
  root:clear_children()

  for _, child in ipairs(children) do
    child = normalize(child)
    if child then
      if #child.children > 0 and child.prop.row == root.prop.row then
        root:add_children(child.children)
      else
        root:add_child(child)
      end
    end
  end

  if #root.children == 0 and not root.prop.win_id then
    return nil
  end

  if #root.children == 1 then
    return root.children[1]
  end

  return root
end

local function move_adj(root, node)
  if node == root then
    return root
  end

  local parent = node.parent

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
  while cur ~= root and not cur.parent.prop.row do
    cur = cur.parent
  end

  if cur ~= root then
    cur.parent:add_child(node, cur:index())
    return root
  end

  return tree.Node:new({ row = true }, { node, cur })
end

local function move_far(root, node)
  return tree.Node:new({ row = true }, { node, root })
end

local function apply(root)
  for _, child in ipairs(root.children) do
    if child.prop.win_id ~= root.prop.win_id then
      vim.fn.win_splitmove(child.prop.win_id, root.prop.win_id, {
        vertical = root.prop.row,
      })
    end
    apply(child)
  end
end

local function build_tree(winlayout)
  if winlayout[1] == 'leaf' then
    local win_id = winlayout[2]
    if config.opts.ignore(win_id) then
      win_id = nil
    end

    return tree.Node:new({ row = false, win_id = win_id })
  end

  local root = tree.Node:new({ row = winlayout[1] == 'row' })
  for _, sub_layout in ipairs(winlayout[2]) do
    root:add_child(build_tree(sub_layout))
  end

  return root
end

local function fill_win_id(root)
  for _, child in ipairs(root.children) do
    fill_win_id(child)
    root.prop.win_id = child.prop.win_id
  end
end

function M.move(win_id, far, dir)
  local root = normalize(build_tree(vim.fn.winlayout()))
  if not root then
    return
  end

  local win_node = tree.search_win(root, win_id)
  assert(win_node, 'Window should exist')

  if directions[dir].diagonal then
    tree.reverse_diagonal(root)
  end
  if directions[dir].horizontal then
    tree.reverse_horizontal(root)
  end

  if far then
    root = move_far(root, win_node)
  else
    root = move_adj(root, win_node)
  end

  if directions[dir].horizontal then
    tree.reverse_horizontal(root)
  end
  if directions[dir].diagonal then
    tree.reverse_diagonal(root)
  end

  root = normalize(root)
  if not root then
    return
  end

  fill_win_id(root)
  apply(root)
  vim.cmd('redraw')
end

return M
