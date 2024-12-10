local M = {}

local highlight_ns = vim.api.nvim_create_namespace('WinMoverLayer')
vim.api.nvim_set_hl(highlight_ns, 'Normal', { bg = '#2e3440' })

function M.new(filtered_win)
  local scratch_buf = vim.api.nvim_create_buf(false, true)
  local layer_win

  return {
    refresh = function()
      local winconf = {
        relative = 'win',
        win = filtered_win,
        width = vim.api.nvim_win_get_width(filtered_win),
        height = vim.api.nvim_win_get_height(filtered_win),
        col = 0,
        row = 0,
        style = 'minimal',
        focusable = false,
      }

      if not layer_win then
        layer_win = vim.api.nvim_open_win(scratch_buf, false, winconf)
      else
        vim.api.nvim_win_set_config(layer_win, winconf)
      end

      vim.api.nvim_win_set_hl_ns(layer_win, highlight_ns)
      vim.api.nvim_set_option_value('winblend', 60, { win = layer_win })
      vim.cmd('redraw')
    end,

    close = function()
      vim.api.nvim_win_close(layer_win, true)
      vim.api.nvim_buf_delete(scratch_buf, { force = true })
      vim.cmd('redraw')
    end,
  }
end

return M
