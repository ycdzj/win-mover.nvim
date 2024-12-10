local tree = require('win-mover.tree')
local utils = require('win-mover.utils')

local M = {}

local function sanitize(root)
  local children = utils.shallow_copy(root.children)
  root:clear_children()
  for _, child in ipairs(children) do
    child = sanitize(child)
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
    local child = root.children[1]
    root:remove_child(child)
    return child
  end
  if #root.children > 0 then
    root.prop.win_id = root.children[#root.children].prop.win_id
  end
  return root
end

local function remove_identical(l1, l2)
  while #l1 > 0 and #l2 > 0 do
    if tree.identical(l1[#l1], l2[#l2]) then
      table.remove(l1, #l1)
      table.remove(l2, #l2)
    elseif tree.identical(l1[1], l2[1]) then
      table.remove(l1, 1)
      table.remove(l2, 1)
    else
      break
    end
  end
end

local function apply(original, updated)
  if original then
    if original.prop.row ~= updated.prop.row then
      apply(nil, updated)
      return
    end
    local original_children = utils.shallow_copy(original.children)
    local updated_children = utils.shallow_copy(updated.children)
    remove_identical(original_children, updated_children)
    if #original_children == 1 and #updated_children == 1 then
      apply(original_children[1], updated_children[1])
    elseif #updated_children > 0 then
      updated:clear_children()
      updated:add_children(updated_children)
      updated.prop.win_id = updated.children[#updated.children].prop.win_id
      apply(nil, updated)
    end
    return
  end

  for _, child in ipairs(updated.children) do
    if child.prop.win_id ~= updated.prop.win_id then
      vim.fn.win_splitmove(child.prop.win_id, updated.prop.win_id, {
        vertical = updated.prop.row,
      })
    end
    apply(nil, child)
  end
end

function M.apply(original_tree, updated_tree)
  original_tree = sanitize(original_tree)
  updated_tree = sanitize(updated_tree)
  if updated_tree then
    apply(original_tree, updated_tree)
  end
end

return M
