local M = {}

M.default_opts = {
  ignore = {
    filetypes = {},
  },
}

M.opts = M.default_opts

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.default_opts, opts or {})
end

function M.is_win_ignored(win_id)
  local buf_id = vim.api.nvim_win_get_buf(win_id)
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf_id })
  return vim.tbl_contains(M.opts.ignore.filetypes, filetype)
end

return M
