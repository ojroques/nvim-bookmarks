Log = {
  tag = 'nvim-bookmarks',
}

function Log.error(msg)
  vim.notify(string.format('(%s) %s', Log.tag, msg), vim.log.levels.ERROR)
end

function Log.warn(msg)
  vim.notify(string.format('(%s) %s', Log.tag, msg), vim.log.levels.WARN)
end

function Log.info(msg)
  vim.notify(string.format('(%s) %s', Log.tag, msg), vim.log.levels.INFO)
end

return Log
