-- Post-render script, run by Quarto through Pandoc (no R needed).
--
-- GitHub Pages runs Jekyll on the published folder unless it holds a
-- `.nojekyll` file. A Quarto render does not write one, so this script does.
--
-- Quarto runs the script in the project folder and passes the output folder
-- as an absolute path (on Windows, for example `C:\...\docs`). Lua opens
-- files through the C library, which on Windows can fail on a name outside
-- the system code page, so an output folder inside the project is opened by
-- its path relative to the project. Pandoc reads both paths as UTF-8.

local function plain(path)
  return (path:gsub("\\", "/"):gsub("/+$", ""))
end

local function from_project(path)
  local prefix = plain(pandoc.system.get_working_directory()) .. "/"
  local full = plain(path)
  if full:sub(1, #prefix):lower() == prefix:lower() then
    return full:sub(#prefix + 1)
  end
  return path
end

local output_dir = pandoc.system.environment().QUARTO_PROJECT_OUTPUT_DIR

if output_dir and output_dir ~= "" then
  local file = assert(io.open(from_project(output_dir) .. "/.nojekyll", "wb"))
  assert(file:close())
end
