local Window = {}

function Window.create(buffer, cwd, namespace, row)
  local width = math.floor(vim.o.columns / 1.618)
  local height = math.min(vim.o.lines, 10)
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

  vim.api.nvim_set_option_value('number', true, {win = win})
  vim.api.nvim_set_option_value('cursorline', true, {win = win})

  if row ~= nil then
    vim.api.nvim_win_set_cursor(win, {row, 0})
  end
end

return Window
