Window = {}

function Window:new(buffer, cwd, namespace, row)
  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor(ui.width / 1.618) -- 1.618 is the golden ratio
  local height = math.min(ui.height, 10)
  local win = vim.api.nvim_open_win(buffer, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'single',
    title = string.format('%s (%s)', vim.fn.fnamemodify(cwd, ':~'), namespace),
  })

  local w = {closed = false, win = win}
  setmetatable(w, self)
  self.__index = self

  vim.api.nvim_set_option_value('number', true, {win = win})
  vim.api.nvim_set_option_value('cursorline', true, {win = win})

  if row ~= nil then
    vim.api.nvim_win_set_cursor(win, {row, 0})
  end

  return w
end

function Window:close()
  if self.closed then
    return
  end

  vim.api.nvim_win_close(self.win, true)
  self.closed = true
end

return Window
