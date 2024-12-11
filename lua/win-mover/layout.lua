local config = require('win-mover.config')
local tree = require('win-mover.tree')

local function prop(win_id, is_ignored)
  local p = { row = false }

  if config.opts.ignore(win_id) == is_ignored then
    p.win_id = win_id
    p.width = vim.api.nvim_win_get_width(win_id)
    p.height = vim.api.nvim_win_get_height(win_id)
  end

  return p
end

-- Build the layout tree from neovim winlayout.
local function build_tree(winlayout, is_ignored)
  if winlayout[1] == 'leaf' then
    return tree.Node:new(prop(winlayout[2], is_ignored))
  end

  local root = tree.Node:new({ row = winlayout[1] == 'row' })
  for _, sub_layout in ipairs(winlayout[2]) do
    root:add_child(build_tree(sub_layout, is_ignored))
  end

  return root
end

-- Ensure that the following is satified in the layout tree:
-- 1. Each non-leaf node contains more than one child.
-- 2. For each non-root node, node.prop.row ~= node.parent.prop.row
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

local function clear_size(root, clear_height, clear_width)
  if clear_width then
    root.prop.width = nil
  end
  if clear_height then
    root.prop.height = nil
  end
  for _, child in ipairs(root.children) do
    clear_size(child, clear_height, clear_width)
  end
end

-- `node` is inside the layout tree rooted at `root`. Move `node` one step left.
local function move_left(root, node)
  if node == root then
    return root
  end
  clear_size(node, true, true)

  local parent = node.parent

  if not parent.prop.row then
    local next = node:next()
    if next then
      local index = node:index()
      local row_node = tree.Node:new({ row = true }, { node, next })
      clear_size(row_node, true, true)
      parent:add_child(row_node, index)
      return root
    end
  end

  local prev = node:prev()
  if prev then
    local index = prev:index()
    local col_node = tree.Node:new({ row = not parent.prop.row }, { node, prev })
    clear_size(col_node, true, true)
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
  clear_size(cur.parent, false, true)
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

local function apply_size(root)
  if root.prop.width then
    vim.api.nvim_win_set_width(root.prop.win_id, root.prop.width)
  end
  if root.prop.height then
    vim.api.nvim_win_set_height(root.prop.win_id, root.prop.height)
  end
  for _, child in ipairs(root.children) do
    apply_size(child)
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
-- left, and then reversing the layout tree back. Note that reversion occurs in memory and we
-- don't actually reverse the neovim window layout.
local directions = {
  left = { diagonal = false, horizontal = false },
  right = { diagonal = false, horizontal = true },
  up = { diagonal = true, horizontal = false },
  down = { diagonal = true, horizontal = true },
}

local M = {}

function M.move(win_id, far, dir)
  local winlayout = vim.fn.winlayout()
  local root = normalize(build_tree(winlayout, false))
  local ignored_wins = build_tree(winlayout, true)

  if not root then
    return
  end

  local win_node = search_win(root, win_id)
  assert(win_node, 'Window should exist')

  if directions[dir].diagonal then
    reverse_diagonal(root)
  end
  if directions[dir].horizontal then
    reverse_horizontal(root)
  end

  if far then
    root = move_far_left(root, win_node)
  else
    root = move_left(root, win_node)
  end

  if directions[dir].horizontal then
    reverse_horizontal(root)
  end
  if directions[dir].diagonal then
    reverse_diagonal(root)
  end

  root = normalize(root)
  apply_layout(root)
  apply_size(root)
  apply_size(ignored_wins)
  vim.cmd('redraw')
end

return M
