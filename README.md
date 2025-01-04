# win-mover.nvim

`win-mover.nvim` is a plugin that helps you move neovim windows easily.

![Demo](./doc/demo.gif)

## Features

- Window Move Mode similar to [WinShift.nvim](https://github.com/sindrets/winshift.nvim)
- Ignore side windows so they stay where they are
- Simple implementation

## Requirements

- Neovim >= 0.7.2

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

```
Plug 'ycdzj/win-mover.nvim'
```

Then call `require('win-mover').setup` with your configuration before using this plugin.

## Example Configuration

- Key bindings: `h,j,k,l` to move window, `q/<Esc>` to quit
- Ignore windows such as `NvimTree`, `neo-tree`, etc. to make them stay on the side

```lua
local win_mover = require('win-mover')
win_mover.setup({
  ignore = {
    enable = true,
    filetypes = { 'NvimTree', 'neo-tree', 'Outline', 'toggleterm' },
  },
  mover_mode = {
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
```

## Commands

`:WinMover`: Enter Window Move Mode

## Default Configuration

Below are the defaults. You only need to specify what want to overwrite in your configuration.

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
  mover_mode = {
    keymap = {},
  },
}
```
