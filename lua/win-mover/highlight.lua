local M = {}

local highlight_ns = vim.api.nvim_create_namespace('WinMoverLayer')
vim.api.nvim_set_hl(highlight_ns, 'Normal', { bg = '#2e3440' })

-- Create a semi-transparent floating window above the window specified by `win` for highlight
-- purposes.
function M.new(win)
  local scratch_buf = vim.api.nvim_create_buf(false, true)
  local float_win = vim.api.nvim_open_win(scratch_buf, false, {
    relative = 'win',
    win = win,
    width = vim.api.nvim_win_get_width(win),
    height = vim.api.nvim_win_get_height(win),
    col = 0,
    row = 0,
    style = 'minimal',
    focusable = false,
  })

  vim.api.nvim_win_set_hl_ns(float_win, highlight_ns)
  vim.api.nvim_set_option_value('winblend', 60, { win = float_win })

  return {
    refresh = function()
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)
      vim.api.nvim_win_set_width(float_win, width)
      vim.api.nvim_win_set_height(float_win, height)
      vim.cmd('redraw')
    end,

    close = function()
      vim.api.nvim_win_close(float_win, true)
      vim.api.nvim_buf_delete(scratch_buf, { force = true })
      vim.cmd('redraw')
    end,
  }
end

return M
