local modpath = core.get_modpath(core.get_current_modname())

ccc = ccc or {}
ccc.state = ccc.state or {}

dofile(modpath .. "/lib/util.lua")
dofile(modpath .. "/content/nodes.lua")

dofile(modpath .. "/lib/state.lua")

dofile(modpath .. "/systems/world.lua")
dofile(modpath .. "/systems/player.lua")
dofile(modpath .. "/systems/player_light.lua")
dofile(modpath .. "/systems/candle_light.lua")
dofile(modpath .. "/systems/wax.lua")
dofile(modpath .. "/systems/hud.lua")
dofile(modpath .. "/systems/candles.lua")
dofile(modpath .. "/systems/torches.lua")
dofile(modpath .. "/systems/plants.lua")
dofile(modpath .. "/systems/ice.lua")
dofile(modpath .. "/systems/doors.lua")
dofile(modpath .. "/systems/game_state.lua")