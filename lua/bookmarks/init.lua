Buffer = require('bookmarks.buffer')
File = require('bookmarks.file')
Namespace = require('bookmarks.namespace')
Shada = require('bookmarks.shada')
Window = require('bookmarks.window')
Bookmarks = {}

local defaults = {
  augroup = 'Bookmarks',
  namespace = '.default',
  shada_dir = string.format('%s/%s', vim.fn.stdpath('data'), 'bookmarks'),
}

function Bookmarks.add()
  local path = vim.api.nvim_buf_get_name(0)
  local pos = vim.api.nvim_win_get_cursor(0)
  local f = File:new(path, pos)
  Bookmarks.shada:add(Bookmarks.namespace, f)
end

function Bookmarks.update()
  local path = vim.api.nvim_buf_get_name(0)
  local pos = vim.api.nvim_win_get_cursor(0)
  local f = File:new(path, pos)
  Bookmarks.shada:update(Bookmarks.namespace, f)
end

function Bookmarks.remove()
  local path = vim.api.nvim_buf_get_name(0)
  local f = File:new(path, nil)
  Bookmarks.shada:remove(Bookmarks.namespace, f)
end

function Bookmarks.open(index)
  local file = Bookmarks.shada:file(Bookmarks.namespace, index)
  if file ~= nil then
    file:edit()
  end
end

function Bookmarks.open_next()
  local path = vim.api.nvim_buf_get_name(0)
  local f = File:new(path, nil)
  local i, _ = Bookmarks.shada:get(Bookmarks.namespace, f)
  if i == nil then
    Bookmarks.open(1)
  else
    Bookmarks.open(i + 1)
  end
end

function Bookmarks.open_previous()
  local path = vim.api.nvim_buf_get_name(0)
  local f = File:new(path, nil)
  local i, _ = Bookmarks.shada:get(Bookmarks.namespace, f)
  if i == nil then
    Bookmarks.open(Bookmarks.shada:length(Bookmarks.namespace))
  else
    Bookmarks.open(i - 1)
  end
end

function Bookmarks.reset(files)
  Bookmarks.shada:purge(Bookmarks.namespace)

  if files == nil then
    return
  end

  for _, f in ipairs(files) do
    Bookmarks.shada:add(Bookmarks.namespace, f)
  end
end

function Bookmarks.toggle_menu()
  if Bookmarks.bookmark_manager ~= nil then
    Bookmarks.bookmark_manager:close()
  end

  local callbacks = {
    on_select = function(file) if file ~= nil then file:edit() end end,
    on_write = function(files) Bookmarks.reset(files) end,
    on_close = function() Bookmarks.bookmark_manager = nil end,
  }

  Bookmarks.bookmark_manager = Buffer:new(Bookmarks.shada:files(Bookmarks.namespace), defaults.augroup, callbacks)

  local path = vim.api.nvim_buf_get_name(0)
  local row, _ = Bookmarks.shada:get(Bookmarks.namespace, File:new(path, nil))

  Window:new(Bookmarks.bookmark_manager.buf, Bookmarks.cwd, Bookmarks.namespace, row)
end

local function on_vim_leave(_)
  if Bookmarks.shada ~= nil then
    Bookmarks.shada:save()
  end
end

local function on_buf_leave(_)
  Bookmarks.namespace = Namespace.git_branch(vim.fn.getcwd()) or defaults.namespace
  Bookmarks.update()
end

local function on_dir_changed(args)
  if Bookmarks.shada ~= nil then
    Bookmarks.shada:save()
  end

  Bookmarks.cwd = args.file
  Bookmarks.namespace = Namespace.git_branch(Bookmarks.cwd) or defaults.namespace
  Bookmarks.shada = Shada:new(defaults.shada_dir, Bookmarks.cwd)
end

local function create_autocommands()
  local group = vim.api.nvim_create_augroup(defaults.augroup, {})
  vim.api.nvim_create_autocmd('VimLeave', {group = group, callback = on_vim_leave})
  vim.api.nvim_create_autocmd('BufLeave', {group = group, callback = on_buf_leave})
  vim.api.nvim_create_autocmd('DirChangedPre', {group = group, callback = on_dir_changed})
end

function Bookmarks.setup()
  on_dir_changed({file = vim.fn.getcwd()})
  create_autocommands()
end

return Bookmarks
