-- Bootstrap. Loads the registry, registers each module, binds the
-- chooser hotkey from here (so a broken module can't strand reload).

require("hs.ipc")  -- enables `hs -c "..."` for programmatic reloads

local registry = require("core.registry")
local chooser  = require("core.chooser")

registry.register(require("modules.timer"))
registry.register(require("modules.calendar"))
registry.register(require("modules.ambient"))
registry.register(require("modules.progress_bar"))
registry.register(require("modules.tooltip"))

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "M", function() chooser.open(registry) end)

hs.alert.show("Progress bar loaded · " .. table.concat(registry.list(), ", "))
