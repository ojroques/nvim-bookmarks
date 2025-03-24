Buffer = require('bookmarks.buffer')
File = require('bookmarks.file')
Namespace = require('bookmarks.namespace')
Shada = require('bookmarks.shada')
Window = require('bookmarks.window')
M = {}

local defaults = {
  augroup = 'Bookmarks',
  namespace = '.default',
  shada_dir = string.format('%s/%s', vim.fn.stdpath('data'), 'bookmarks'),
}

function M.add()
  local path = vim.api.nvim_buf_get_name(0)
  local pos = vim.api.nvim_win_get_cursor(0)
  local f = File:new(path, pos)
  M.shada:add(M.namespace, f)
end

function M.update()
  local path = vim.api.nvim_buf_get_name(0)
  local pos = vim.api.nvim_win_get_cursor(0)
  local f = File:new(path, pos)
  M.shada:update(M.namespace, f)
end

function M.remove()
  local path = vim.api.nvim_buf_get_name(0)
  local f = File:new(path, nil)
  M.shada:remove(M.namespace, f)
end

function M.open(index)
  local file = M.shada:file(M.namespace, index)
  if file ~= nil then
    file:edit()
  end
end

function M.open_next()
  local path = vim.api.nvim_buf_get_name(0)
  local f = File:new(path, nil)
  local i, _ = M.shada:get(M.namespace, f)
  if i == nil then
    M.open(1)
  else
    M.open(i + 1)
  end
end

function M.open_previous()
  local path = vim.api.nvim_buf_get_name(0)
  local f = File:new(path, nil)
  local i, _ = M.shada:get(M.namespace, f)
  if i == nil then
    M.open(M.shada:length(M.namespace))
  else
    M.open(i - 1)
  end
end

function M.reset(files)
  M.shada:purge(M.namespace)

  if files == nil then
    return
  end

  for _, f in ipairs(files) do
    M.shada:add(M.namespace, f)
  end
end

function M.toggle_menu()
  if M.bookmark_manager ~= nil then
    M.bookmark_manager:close()
  end

  local callbacks = {
    on_select = function(file) if file ~= nil then file:edit() end end,
    on_write = function(files) M.reset(files) end,
    on_close = function() M.bookmark_manager = nil end,
  }

  M.bookmark_manager = Buffer:new(M.shada:files(M.namespace), defaults.augroup, callbacks)

  local path = vim.api.nvim_buf_get_name(0)
  local row, _ = M.shada:get(M.namespace, File:new(path, nil))

  Window:new(M.bookmark_manager.buf, M.cwd, M.namespace, row)
end

local function on_vim_leave(_)
  if M.shada ~= nil then
    M.shada:save()
  end
end

local function on_buf_leave(_)
  M.namespace = Namespace.git_branch(vim.fn.getcwd()) or defaults.namespace
  M.update()
end

local function on_dir_changed(args)
  if M.shada ~= nil then
    M.shada:save()
  end

  M.cwd = args.file
  M.namespace = Namespace.git_branch(M.cwd) or defaults.namespace
  M.shada = Shada:new(defaults.shada_dir, M.cwd)
end

local function create_autocommands()
  local group = vim.api.nvim_create_augroup(defaults.augroup, {})
  vim.api.nvim_create_autocmd('VimLeave', {group = group, callback = on_vim_leave})
  vim.api.nvim_create_autocmd('BufLeave', {group = group, callback = on_buf_leave})
  vim.api.nvim_create_autocmd('DirChangedPre', {group = group, callback = on_dir_changed})
end

function M.setup()
  on_dir_changed({file = vim.fn.getcwd()})
  create_autocommands()
end

return M
