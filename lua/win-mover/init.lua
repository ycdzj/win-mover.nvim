local layout = require('win-mover.layout')
local filter = require('win-mover.filter')
local mover = require('win-mover.mover')
local tree = require('win-mover.tree')
local utils = require('win-mover.utils')

local M = {}

local config = {
  ignore = function(win_id)
    return false
  end,
}

local function remove_ignored(root)
  local children = utils.shallow_copy(root.children)
  for _, child in ipairs(children) do
    remove_ignored(child)
    if child.prop.win_id and config.ignore(child.prop.win_id) then
      root:remove_child(child)
    end
  end
end

local function move(win_id, updater, reverse)
  local win_layout = vim.fn.winlayout()
  local updated_tree = tree.build_from_layout(win_layout)
  local original_tree = tree.build_from_layout(win_layout)

  remove_ignored(updated_tree)
  remove_ignored(original_tree)

  local win_node = tree.search_win(updated_tree, win_id)
  assert(win_node, 'Window should exist')
  updated_tree = mover.move(updated_tree, win_node, updater, reverse)

  layout.apply(original_tree, updated_tree)
  vim.cmd('redraw')
end

function M.enter_move_mode()
  local cur_win = vim.api.nvim_get_current_win()
  if config.ignore(cur_win) then
    return
  end

  local filter_win = filter.new(cur_win)
  while true do
    filter_win.refresh()

    vim.api.nvim_echo({ { '-- Window Move Mode --' } }, false, {})
    local input = utils.getchar()

    if input == 'q' then
      vim.api.nvim_echo({ { '' } }, false, {})
      break
    end

    if input == 'h' then
      move(cur_win, mover.updater.adj, mover.reverse.left)
    elseif input == 'j' then
      move(cur_win, mover.updater.adj, mover.reverse.down)
    elseif input == 'k' then
      move(cur_win, mover.updater.adj, mover.reverse.up)
    elseif input == 'l' then
      move(cur_win, mover.updater.adj, mover.reverse.right)
    elseif input == 'H' then
      move(cur_win, mover.updater.far, mover.reverse.left)
    elseif input == 'J' then
      move(cur_win, mover.updater.far, mover.reverse.down)
    elseif input == 'K' then
      move(cur_win, mover.updater.far, mover.reverse.up)
    elseif input == 'L' then
      move(cur_win, mover.updater.far, mover.reverse.right)
    end
  end

  filter_win.close()
end

function M.setup(setup_config)
  setup_config = setup_config or {}
  utils.merge_table(config, setup_config)
end

return M
