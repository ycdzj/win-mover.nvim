local config = require('win-mover.config')
local highlight = require('win-mover.highlight')
local layout = require('win-mover.layout')
local utils = require('win-mover.utils')

local function move_mode_loop(cur_win, highlight_win)
  while true do
    highlight_win.refresh()
    vim.api.nvim_echo({ { '-- Window Move Mode --' } }, false, {})
    local input = config.opts.move_mode.keymap[utils.getchar()]
    if input then
      if input.quit then
        vim.api.nvim_echo({ { '' } }, false, {})
        break
      end
      layout.move(cur_win, input.far, input.direction)
    end
  end
end

local M = {}

function M.enter_move_mode()
  if next(config.opts.move_mode.keymap) == nil then
    print('Win-mover: cannot enter Window Move Mode because keymap is not configured')
    return
  end

  local cur_win = vim.api.nvim_get_current_win()
  if config.is_win_ignored(cur_win) then
    return
  end

  local highlight_win = highlight.new(cur_win)
  local ok, result = pcall(move_mode_loop, cur_win, highlight_win)
  if not ok then
    print('Win-mover encountered error:', result)
  end
  highlight_win.close()
end

function M.setup(opts)
  config.setup(opts)
end

M.ops = {
  move_left = { far = false, direction = 'left' },
  move_right = { far = false, direction = 'right' },
  move_up = { far = false, direction = 'up' },
  move_down = { far = false, direction = 'down' },
  move_far_left = { far = true, direction = 'left' },
  move_far_right = { far = true, direction = 'right' },
  move_far_up = { far = true, direction = 'up' },
  move_far_down = { far = true, direction = 'down' },
  quit = { quit = true },
}

return M
