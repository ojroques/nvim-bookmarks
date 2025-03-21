File = {
  pos = {1, 0},
}

function File:new(path, pos)
  local f = {path = path, pos = pos}
  setmetatable(f, self)
  self.__index = self
  return f
end

function File:from_string(s)
  local _, _, pretty_path, row, col = string.find(s, '(.+) |(%d+), (%d+)|')
  if pretty_path == nil or row == nil or col == nil then
    return nil
  end
  return File:new(vim.fn.fnamemodify(pretty_path, ':p'), {tonumber(row), tonumber(col)})
end

function File:to_string()
  return string.format('%s |%d, %d|', self:pretty_path(), self.pos[1], self.pos[2])
end

function File:edit()
  local buffer = vim.fn.bufadd(self.path)
  vim.api.nvim_set_option_value('buflisted', true, {buf = buffer})
  vim.api.nvim_win_set_buf(0, buffer)
  vim.api.nvim_win_set_cursor(0, self.pos)
end

function File:readable()
  return vim.fn.filereadable(self.path) == 1
end

function File:pretty_path()
  return vim.fn.fnamemodify(self.path, ':~:.')
end

function File:__eq(other)
  return self.path == other.path
end

function File:__tostring()
  return self:to_string()
end

return File
