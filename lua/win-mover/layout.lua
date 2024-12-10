local tree = require('win-mover.tree')
local utils = require('win-mover.utils')

local M = {}

function M.normalize(root)
  local children = utils.shallow_copy(root.children)
  root:clear_children()
  for _, child in ipairs(children) do
    child = M.normalize(child)
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

function M.apply(original, updated)
  if original then
    if original.prop.row ~= updated.prop.row then
      M.apply(nil, updated)
      return
    end
    local original_children = utils.shallow_copy(original.children)
    local updated_children = utils.shallow_copy(updated.children)
    remove_identical(original_children, updated_children)
    if #original_children == 1 and #updated_children == 1 then
      M.apply(original_children[1], updated_children[1])
    elseif #updated_children > 0 then
      updated:clear_children()
      updated:add_children(updated_children)
      updated.prop.win_id = updated.children[#updated.children].prop.win_id
      M.apply(nil, updated)
    end
    return
  end

  for _, child in ipairs(updated.children) do
    if child.prop.win_id ~= updated.prop.win_id then
      print(child.prop.win_id)
      print(updated.prop.win_id)
      vim.fn.win_splitmove(child.prop.win_id, updated.prop.win_id, {
        vertical = updated.prop.row,
      })
    end
    M.apply(nil, child)
  end
end

function M.build_from_winlayout(winlayout)
  if winlayout[1] == 'leaf' then
    return tree.Node:new({ row = false, win_id = winlayout[2] })
  end

  local root = tree.Node:new({ row = winlayout[1] == 'row' })
  for _, sub_layout in ipairs(winlayout[2]) do
    root:add_child(M.build_from_winlayout(sub_layout))
  end
  return root
end

return M
