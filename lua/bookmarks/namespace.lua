Namespace = {}

function Namespace.git_branch(cwd)
  local result = vim.system({'git', 'branch', '--show-current'}, {cwd = cwd}):wait(1000)

  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout)
end

return Namespace
