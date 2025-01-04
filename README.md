# win-mover.nvim

`win-mover.nvim` is a plugin that helps you move Neovim windows easily.

![Demo](./doc/demo.gif)

## Features

- Window Move Mode similar to [WinShift.nvim](https://github.com/sindrets/winshift.nvim)
- Ignore side windows (e.g. NvimTree) so they will not move
- Simple implementation

## Requirements

- Neovim >= 0.8.0

## Installation

Install it with your favorite plugin manager:

### lazy

```lua
{
  'ycdzj/win-mover.nvim',
  lazy = false,
  config = function()
    local win_mover = require('win-mover')
    win_mover.setup({}) -- configuration goes here
  end,
}
```

### packer

```lua
use {
  'ycdzj/win-mover.nvim',
  config = function()
    local win_mover = require('win-mover')
    win_mover.setup({}) -- configuration goes here
  end,
}
```

### vim-plug

1. Add this to your config:
    ```vim
    Plug 'ycdzj/win-mover.nvim'
    ```
2. Call `require('win-mover').setup` with your configuration before using this plugin.

## Configuration

### Defaults

```lua
{
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
```

### Example

This is an example configuration that:

- Binds `<leader>e` for entering Move Mode.
- `h,j,k,l` to move window in Move Mode.
- `q` or `<Esc>` to quit Move Mode.
- Ignores windows such as `NvimTree`, `neo-tree`, etc.

```lua
local win_mover = require('win-mover')
win_mover.setup({
  ignore = {
    enable = true,
    filetypes = { 'NvimTree', 'neo-tree', 'Outline', 'toggleterm' },
  },
  move_mode = {
    keymap = {
      h = win_mover.ops.move_left,
      j = win_mover.ops.move_down,
      k = win_mover.ops.move_up,
      l = win_mover.ops.move_right,

      H = win_mover.ops.move_far_left,
      J = win_mover.ops.move_far_down,
      K = win_mover.ops.move_far_up,
      L = win_mover.ops.move_far_right,

      q = win_mover.ops.quit,
      ['<Esc>'] = win_mover.ops.quit,
    },
  },
})
vim.keymap.set("n", "<leader>e", win_mover.enter_move_mode, { noremap = true, silent = true })
```

## Commands

- `:WinMover`

    Enter Window Move Mode

