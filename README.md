# win-mover.nvim

`win-mover.nvim` is a plugin that helps you move neovim windows easily.

![Demo](./doc/demo.gif)

## Features

- Window Mover Mode similar to [WinShift.nvim](https://github.com/sindrets/winshift.nvim)
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
  opts = {}, -- your configuration goes here
}
```

### packer

```lua
use {
  'ycdzj/win-mover.nvim',
  config = function()
    require('win-mover').setup({}) -- your configuration goes here
  end,
}
```

### vim-plug

```
Plug 'ycdzj/win-mover.nvim'
```

Then call `require('win-mover').setup` before using this plugin.

## Configuration

Below is the default configuration. Call `require('win-mover').setup` with the items you want to overwrite.

```lua
{
  ignore = {
    filetypes = { 'NvimTree', 'Outline', 'toggleterm' },
  },
}
```

## Commands & Lua APIs

