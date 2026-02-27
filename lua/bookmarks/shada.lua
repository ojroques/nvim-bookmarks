local File = require('bookmarks.file')
local Log = require('bookmarks.log')
local Shada = {}

function Shada:new(shada_dir, cwd)
  local s = {path = string.format('%s/%s.json', shada_dir, vim.uri_encode(cwd, 'rfc2396')), data = {}}
  setmetatable(s, self)
  self.__index = self
  s:load()
  return s
end

function Shada:add(namespace, file)
  if not file:readable() then
    Log.warn(string.format('%s is not readable', file:pretty_path()))
    return
  end

  if self.data[namespace] == nil then
    self.data[namespace] = {}
  end

  for i, f in ipairs(self.data[namespace]) do
    if f == file then
      self.data[namespace][i] = file
      return
    end
  end

  table.insert(self.data[namespace], file)
end

function Shada:get(namespace, file)
  if self.data[namespace] == nil then
    return nil
  end

  for i, f in ipairs(self.data[namespace]) do
    if f == file then
      return i
    end
  end

  return nil
end

function Shada:update(namespace, file)
  if self.data[namespace] == nil then
    return
  end

  for i, f in ipairs(self.data[namespace]) do
    if f == file then
      self.data[namespace][i] = file
      return
    end
  end
end

function Shada:remove(namespace, file)
  if self.data[namespace] == nil then
    return
  end

  for i, f in ipairs(self.data[namespace]) do
    if f == file then
      table.remove(self.data[namespace], i)
      return
    end
  end
end

function Shada:file(namespace, index)
  if self.data[namespace] == nil then
    return nil
  end

  return self.data[namespace][index]
end

function Shada:files(namespace)
  if self.data[namespace] == nil then
    return nil
  end

  return self.data[namespace]
end

function Shada:length(namespace)
  if self.data[namespace] == nil then
    return 0
  end

  return #self.data[namespace]
end

function Shada:clean()
  local data = {}

  for ns, files in pairs(self.data) do
    local cleaned = vim.tbl_map(function(f) return File:new(f.path, f.pos) end, files)
    cleaned = vim.tbl_filter(function(f) return f:readable() end, cleaned)

    if not vim.tbl_isempty(cleaned) then
      data[ns] = cleaned
    end
  end

  self.data = data
end

function Shada:purge(namespace)
  self.data[namespace] = nil
end

function Shada:load()
  if vim.fn.filereadable(self.path) == 0 then
    return
  end

  local data = vim.fn.readfile(self.path)

  if vim.tbl_isempty(data) then
    Log.error('Failed to load data')
    return
  end

  self.data = vim.json.decode(data[1])

  self:clean()
end

function Shada:save()
  self:clean()

  if vim.tbl_isempty(self.data) then
    vim.fn.delete(self.path)
    return
  end

  local data = vim.json.encode(self.data)

  if vim.fn.mkdir(vim.fn.fnamemodify(self.path, ':p:h'), 'p') == 0 then
    Log.error('Failed to create data directory')
    return
  end

  if vim.fn.writefile({data}, self.path) == -1 then
    Log.error('Failed to save data')
    return
  end
end

return Shada
