--i don't have time for a 3d model

local function update_visual(player, wax_percent)
	local scale = 0.55 + 0.45 * (wax_percent / 100)
	player:set_properties({
		visual = "mesh",
		mesh = "ccc_candle.obj",
		textures = {"ccc_candle.png"},
		visual_size = {x = scale, y = scale, z = scale},
		collisionbox = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
		selectionbox = {-0.35, -0.6, -0.35, 0.35, 0.6, 0.35},
		stepheight = 0.6,
	})
	player:set_physics_override({speed = 1.0, jump = 1.0, gravity = 1.0})
end

function ccc.update_candle_visual(player, wax_percent)
	update_visual(player, wax_percent)
end

core.register_on_joinplayer(function(player)
	local state = ccc.state_api.get(player)
	state.joined = true
	update_visual(player, state.wax)
end)
