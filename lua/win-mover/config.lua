local M = {}

M.default_opts = {
  ignore = {
    enable = false,
    filetypes = {},
  },
  highlight = {
    color = '#2e3440',
    transparency = 60,
  },
  move_mode = {
    keymap = {},
  },
}

M.highlight_ns = vim.api.nvim_create_namespace('WinMoverLayer')

local function replace_termcodes(keymap)
  local new_keymap = {}
  for key, val in pairs(keymap) do
    local replaced_key = vim.api.nvim_replace_termcodes(key, true, false, true)
    new_keymap[replaced_key] = val
  end
  return new_keymap
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.default_opts, opts or {})
  M.opts.move_mode.keymap = replace_termcodes(M.opts.move_mode.keymap)
  vim.api.nvim_set_hl(M.highlight_ns, 'Normal', { bg = M.opts.highlight.color })
end

function M.is_win_ignored(win_id)
  if not M.opts.ignore.enable then
    return false
  end
  local buf_id = vim.api.nvim_win_get_buf(win_id)
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf_id })
  return vim.tbl_contains(M.opts.ignore.filetypes, filetype)
end

return M
