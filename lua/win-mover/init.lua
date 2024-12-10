local layout = require('win-mover.layout')
local highlight = require('win-mover.highlight')
local mover = require('win-mover.mover')
local tree = require('win-mover.tree')
local utils = require('win-mover.utils')
local config = require('win-mover.config')

local M = {}

local function remove_ignored(root)
  local children = utils.shallow_copy(root.children)
  for _, child in ipairs(children) do
    remove_ignored(child)
    if child.prop.win_id and config.opts.ignore(child.prop.win_id) then
      root:remove_child(child)
    end
  end
end

local function move(win_id, updater, reverse)
  local original_tree = layout.build_from_winlayout(vim.fn.winlayout())
  remove_ignored(original_tree)

  original_tree = layout.normalize(original_tree)
  if not original_tree then
    return
  end

  local updated_tree = original_tree:copy()
  local win_node = tree.search_win(updated_tree, win_id)
  assert(win_node, 'Window should exist')

  updated_tree = mover.move(updated_tree, win_node, updater, reverse)
  updated_tree = layout.normalize(updated_tree)
  if not updated_tree then
    return
  end

  layout.apply(original_tree, updated_tree)
  vim.cmd('redraw')
end

function M.enter_move_mode()
  local cur_win = vim.api.nvim_get_current_win()
  if config.opts.ignore(cur_win) then
    return
  end

  local highlight_win = highlight.new(cur_win)
  while true do
    highlight_win.refresh()

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

  highlight_win.close()
end

function M.setup(opts)
  config.setup(opts)
end

return M
