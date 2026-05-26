-- Module chooser. Hotkey-driven hs.chooser listing every loaded module
-- with its status() subtitle. Selecting a row reloads that module.

local M = {}

local function rowsFor(registry)
  local rows = {}
  for _, name in ipairs(registry.list()) do
    rows[#rows + 1] = {
      text    = name,
      subText = registry.status(name),
      name    = name,
    }
  end
  return rows
end

function M.open(registry)
  local chooser = hs.chooser.new(function(choice)
    if choice and choice.name then registry.reload(choice.name) end
  end)
  chooser:choices(rowsFor(registry))
  chooser:placeholderText("reload module")
  chooser:show()
end

return M
