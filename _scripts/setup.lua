-- Pre-render script, run by Quarto through Pandoc (no R needed).
--
-- `quarto use template` does not copy dotfiles or README.md, so the template
-- ships them under other names. This script gives them their real names.
--
-- When `.gitignore` already exists (Quarto writes one in a git repository
-- before this script runs), the template's lines that it lacks are appended,
-- so the ignore rules for fitted models are never lost. The file then ends
-- with `!docs/` and `!_freeze/`, because in git the last matching rule wins,
-- so an earlier `docs/` rule cannot keep the site out of git. An existing
-- README.md is kept as it is, and the template's README is removed. The
-- guide for authors ships as GUIDE.md, which this script leaves alone.
--
-- Quarto runs the script in the project folder, so the file names are
-- relative to it. Files are read and written as bytes, so their line
-- endings stay as they are, and a step that fails stops the render.

-- A path exists unless opening it fails with "no such file" (error 2), so a
-- file that cannot be read still counts as there.
local function exists(path)
  local file, _, code = io.open(path, "rb")
  if file then
    file:close()
    return true
  end
  return code ~= 2
end

local function read(path)
  local file = assert(io.open(path, "rb"))
  local text = assert(file:read("a"))
  file:close()
  return text
end

-- Appending leaves the existing bytes in place if the write fails.
local function append(path, text)
  local file = assert(io.open(path, "ab"))
  assert(file:write(text))
  assert(file:close())
end

-- The lines of `text`, split at each LF or CR LF.
local function split_lines(text)
  local lines = {}
  local start = 1
  while true do
    local from, to = text:find("\r?\n", start)
    if not from then
      lines[#lines + 1] = text:sub(start)
      return lines
    end
    lines[#lines + 1] = text:sub(start, from - 1)
    start = to + 1
  end
end

local function blank(line)
  return line:match("^%s*$") ~= nil
end

local keep_last = { "!docs/", "!_freeze/" }

local function is_keep_last(line)
  return line == keep_last[1] or line == keep_last[2]
end

local function merge_lines(src, dest)
  local current = read(dest)
  local have = {}
  local lines = {}
  for _, line in ipairs(split_lines(current)) do
    have[line] = true
    if not blank(line) then lines[#lines + 1] = line end
  end

  local add = {}
  for _, line in ipairs(split_lines(read(src))) do
    if not blank(line) and not have[line] and not is_keep_last(line) then
      add[#add + 1] = line
      lines[#lines + 1] = line
    end
  end

  local n = #lines
  if not (n >= 2 and lines[n - 1] == keep_last[1] and lines[n] == keep_last[2]) then
    add[#add + 1] = keep_last[1]
    add[#add + 1] = keep_last[2]
  end

  if #add > 0 then
    local sep = (current == "" or current:sub(-1) == "\n") and "" or "\n"
    append(dest, sep .. table.concat(add, "\n") .. "\n")
  end
end

if exists("_gitignore") then
  if exists(".gitignore") then
    merge_lines("_gitignore", ".gitignore")
    assert(os.remove("_gitignore"))
  else
    assert(os.rename("_gitignore", ".gitignore"))
  end
end

if exists("_README.md") then
  if not exists("README.md") then
    assert(os.rename("_README.md", "README.md"))
  else
    assert(os.remove("_README.md"))
  end
end
