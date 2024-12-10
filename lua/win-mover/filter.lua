local M = {}

local highlight_ns = vim.api.nvim_create_namespace('WinMoverLayer')
vim.api.nvim_set_hl(highlight_ns, 'Normal', { bg = '#2e3440' })

function M.create(filtered_win)
  local scratch_buf = vim.api.nvim_create_buf(false, true)
  local layer_win = vim.api.nvim_open_win(scratch_buf, false, {
    relative = 'win',
    width = vim.api.nvim_win_get_width(filtered_win),
    height = vim.api.nvim_win_get_height(filtered_win),
    col = 0,
    row = 0,
    style = 'minimal',
    focusable = false,
  })
  vim.api.nvim_win_set_hl_ns(layer_win, highlight_ns)
  vim.api.nvim_set_option_value('winblend', 60, { win = layer_win })
  return {
    close = function()
      vim.api.nvim_win_close(layer_win, true)
      vim.api.nvim_buf_delete(scratch_buf, { force = true })
    end,
  }
end

return M
