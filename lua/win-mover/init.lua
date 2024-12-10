local config = require('win-mover.config')
local highlight = require('win-mover.highlight')
local layout = require('win-mover.layout')
local utils = require('win-mover.utils')

local directions = { h = 'left', l = 'right', k = 'up', j = 'down' }

local M = {}

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

    local direction = directions[string.lower(input)]
    if direction then
      local far = (input == string.upper(input))
      layout.move(cur_win, far, direction)
    end
  end

  highlight_win.close()
end

function M.setup(opts)
  config.setup(opts)
end

return M
