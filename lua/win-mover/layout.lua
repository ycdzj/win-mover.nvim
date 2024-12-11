local config = require('win-mover.config')
local tree = require('win-mover.tree')

-- Build the layout tree from neovim winlayout.
local function build_tree(winlayout)
  if winlayout[1] == 'leaf' then
    local win_id = winlayout[2]
    return tree.Node:new({
      row = false,
      win_id = win_id,
      ignored = config.opts.ignore(win_id),
      width = vim.api.nvim_win_get_width(win_id),
      height = vim.api.nvim_win_get_height(win_id),
    })
  end

  local root = tree.Node:new({ row = winlayout[1] == 'row' })
  for _, sub_layout in ipairs(winlayout[2]) do
    root:add_child(build_tree(sub_layout))
  end

  return root
end

-- Create a new tree that satisfies the following conditions:
-- 1. Each non-leaf node contains more than one child.
-- 2. For each non-root node, `node.prop.row` is not equal to `node.parent.prop.row`.
-- 3. All the ignored nodes are removed.
local function normalize(old_node)
  if old_node.prop.ignored then
    return nil
  end

  local new_node = tree.Node:new(old_node.prop)
  for _, child in ipairs(old_node.children) do
    child = normalize(child)
    if child then
      if #child.children > 0 and child.prop.row == new_node.prop.row then
        new_node:add_children(child.children)
      else
        new_node:add_child(child)
      end
    end
  end

  if #new_node.children == 0 and not new_node.prop.win_id then
    return nil
  end

  if #new_node.children == 1 then
    return new_node.children[1]
  end

  return new_node
end

-- `node` is inside the layout tree rooted at `root`. Move `node` one step left.
local function move_left(root, node)
  if node == root then
    return root
  end

  local parent = node.parent

  if not parent.prop.row then
    local next = node:next()
    if next then
      local index = node:index()
      local row_node = tree.Node:new({ row = true }, { node, next })
      parent:add_child(row_node, index)
      return root
    end
  end

  local prev = node:prev()
  if prev then
    local index = prev:index()
    local col_node = tree.Node:new({ row = not parent.prop.row }, { node, prev })
    parent:add_child(col_node, index)
    return root
  end

  assert(parent.prop.row)

  local cur = node.parent
  while cur ~= root and not cur.parent.prop.row do
    cur = cur.parent
  end

  if cur == root then
    root = tree.Node:new({ row = true }, { cur })
  end

  cur.parent:add_child(node, cur:index())
  return root
end

-- `node` is inside the layout tree rooted at `root`. Move `node` to the leftmost position.
local function move_far_left(root, node)
  return tree.Node:new({ row = true }, { node, root })
end

-- For each non-leaf node, assign the id of the last window in the sub-tree to prop.win_id.
local function fill_win_id(root)
  for _, child in ipairs(root.children) do
    fill_win_id(child)
    root.prop.win_id = child.prop.win_id
  end
end

-- Apply the layout tree by updating neovim winlayout.
local function apply_layout(root)
  if not root then
    return
  end

  if not root.prop.win_id then
    fill_win_id(root)
  end

  for _, child in ipairs(root.children) do
    if child.prop.win_id ~= root.prop.win_id then
      vim.fn.win_splitmove(child.prop.win_id, root.prop.win_id, {
        vertical = root.prop.row,
      })
    end
    apply_layout(child)
  end
end

local function restore_ignored_win_size(root)
  if root.prop.ignored then
    vim.api.nvim_win_set_width(root.prop.win_id, root.prop.width)
    vim.api.nvim_win_set_height(root.prop.win_id, root.prop.height)
  end
  for _, child in ipairs(root.children) do
    restore_ignored_win_size(child)
  end
end

local function reverse_diagonal(root)
  root.prop.row = not root.prop.row
  root.prop.width, root.prop.height = root.prop.height, root.prop.width

  for _, child in ipairs(root.children) do
    reverse_diagonal(child)
  end
end

local function reverse_horizontal(root)
  if root.prop.row then
    root:reverse_children()
  end
  for _, child in ipairs(root.children) do
    reverse_horizontal(child)
  end
end

local function search_win(root, win_id)
  for _, child in ipairs(root.children) do
    local node = search_win(child, win_id)
    if node then
      return node
    end
  end
  if root.prop.win_id == win_id then
    return root
  end
  return nil
end

-- We only implement the logic for moving a window to the left. Moving in other directions is
-- achieved by reversing the layout tree diagonally or horizontally, moving the window to the
-- left, and then reversing the layout tree back. Note that reversion occurs in memory only and we
-- don't actually reverse the neovim window layout.
local directions = {
  left = { diagonal = false, horizontal = false },
  right = { diagonal = false, horizontal = true },
  up = { diagonal = true, horizontal = false },
  down = { diagonal = true, horizontal = true },
}

local M = {}

function M.move(win_id, far, dir)
  local old_layout = build_tree(vim.fn.winlayout())
  local new_layout = normalize(old_layout)
  if not new_layout then
    return
  end

  local win_node = search_win(new_layout, win_id)
  assert(win_node, 'Window should exist')

  if directions[dir].diagonal then
    reverse_diagonal(new_layout)
  end
  if directions[dir].horizontal then
    reverse_horizontal(new_layout)
  end

  if far then
    new_layout = move_far_left(new_layout, win_node)
  else
    new_layout = move_left(new_layout, win_node)
  end

  if directions[dir].horizontal then
    reverse_horizontal(new_layout)
  end
  if directions[dir].diagonal then
    reverse_diagonal(new_layout)
  end

  apply_layout(normalize(new_layout))
  restore_ignored_win_size(old_layout)
  vim.cmd('redraw')
end

return M
