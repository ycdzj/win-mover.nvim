local M = {}

M.default_opts = {
  ignore = function(win_id)
    return false
  end,
}

M.opts = M.default_opts

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.default_opts, opts or {})
end

return M
