# nvim-bookmarks

My own implementation of [harpoon](https://github.com/ThePrimeagen/harpoon). It is mainly intended
for my own use. Thus, it deliberately lacks features and configuration options.

The bookmarks are saved as JSON files in `~/.local/share/nvim/bookmarks` by default. Bookmarks are
namespaced according to the current working directory and git branch.

## Usage
In your *init.lua*:
```lua
local bookmarks = require('bookmarks')
bookmarks.setup()

-- Add the current file to bookmarks
vim.keymap.set('n', 'mm', bookmarks.add)

-- Remove the current file from bookmarks
vim.keymap.set('n', 'mM', bookmarks.remove)

-- Open a bookmark in a new buffer
vim.keymap.set('n', 'm1', function() bookmarks.open(1) end)
vim.keymap.set('n', 'm2', function() bookmarks.open(2) end)
vim.keymap.set('n', 'm3', function() bookmarks.open(3) end)
vim.keymap.set('n', 'm4', function() bookmarks.open(4) end)

-- Open previous / next bookmark
vim.keymap.set('n', 'm[', bookmarks.open_previous)
vim.keymap.set('n', 'm]', bookmarks.open_next)

-- Manage bookmarks in a floating window
vim.keymap.set('n', 'M', function() bookmarks.toggle_menu)
```
