local cache = {}

local function rez_info(root)
  if cache[root] then return cache[root] end

  local pkgs = { "flowconfig-local" }
  local f = root .. "/.rez-packages"
  if vim.fn.filereadable(f) == 1 then pkgs = vim.fn.readfile(f) end

  local cmd = { "env", "-u", "PYTHONHOME", "-u", "PYTHONPATH", "rez", "env" }
  vim.list_extend(cmd, pkgs)
  vim.list_extend(cmd, { "--", "sh", "-c",
    [[printf 'PP=%s\nPR=%s\n' "$PYTHONPATH" "$REZ_PYTHON_ROOT"]] })

  local res = vim.system(cmd, { text = true }):wait(60000)
  if res.code ~= 0 then
    vim.notify("rez resolve failed:\n" .. (res.stderr or ""), vim.log.levels.WARN)
    return nil
  end

  local pp, pr
  for _, l in ipairs(vim.split(res.stdout, "\n")) do
    pp = l:match("^PP=(.*)") or pp
    pr = l:match("^PR=(.*)") or pr
  end
  if not pr then return nil end

  cache[root] = {
    exe = pr .. "/python/bin/python3",   -- matches your PYTHONHOME layout
    path = vim.split(pp or "", ":", { trimempty = true }),
  }
  return cache[root]
end
