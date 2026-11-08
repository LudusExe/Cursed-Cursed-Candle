local modpath = core.get_modpath(core.get_current_modname())

ccc = ccc or {}
ccc.modpath = modpath
ccc.state = {}

local function load(path)
	dofile(modpath .. "/" .. path)
end

load("lib/util.lua")
load("content/nodes.lua")
load("lib/state.lua")

load("systems/world.lua")
load("systems/player.lua")
load("systems/player_light.lua")
load("systems/wax.lua")
load("systems/hud.lua")
load("systems/candles.lua")
load("systems/torches.lua")
load("systems/game_state.lua")