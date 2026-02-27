local File = require('bookmarks.file')
local Buffer = {}

local function invoke(callbacks, name, ...)
  if callbacks and callbacks[name] then
    callbacks[name](...)
  end
end

function Buffer:new(files, augroup, callbacks)
  local buf = vim.api.nvim_create_buf(false, true)

  local b = {closed = false, buf = buf, callbacks = callbacks}
  setmetatable(b, self)
  self.__index = self

  vim.api.nvim_buf_set_name(buf, string.format('bookmarks.%d', buf))
  vim.api.nvim_set_option_value('buftype', 'acwrite', {buf = buf})
  vim.api.nvim_set_option_value('filetype', 'bookmarks', {buf = buf})
  vim.api.nvim_set_option_value('syntax', 'bookmarks', {buf = buf})

  if files ~= nil then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.tbl_map(function(f) return f:to_string() end, files))
  end

  vim.api.nvim_create_autocmd({'BufWriteCmd'}, {group = augroup, buffer = buf, callback = function() b:write() end})
  vim.api.nvim_create_autocmd({'BufLeave'}, {group = augroup, buffer = buf, callback = function() b:close() end})

  vim.keymap.set('n', 'q', function() b:close() end, {buffer = buf, silent = true})
  vim.keymap.set('n', '<Esc>', function() b:close() end, {buffer = buf, silent = true})
  vim.keymap.set('n', '<CR>', function() b:select() end, {buffer = buf, silent = true})

  return b
end

function Buffer:select()
  if self.closed then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(self.buf, pos[1] - 1, pos[1], false)
  local file = File:from_string(line[1])

  self:close()
  invoke(self.callbacks, 'on_select', file)
end

function Buffer:write()
  if self.closed then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
  local files = vim.tbl_map(function(l) return File:from_string(l) end, lines)
  files = vim.tbl_filter(function(f) return f ~= nil end, files)

  self:close()
  invoke(self.callbacks, 'on_write', files)
end

function Buffer:close()
  if self.closed then
    return
  end

  vim.api.nvim_buf_delete(self.buf, {force = true})
  self.closed = true

  invoke(self.callbacks, 'on_close')
end

return Buffer
