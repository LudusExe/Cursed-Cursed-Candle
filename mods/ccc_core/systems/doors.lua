local CHECK_INTERVAL = 0.5


core.register_node("ccc_core:magic_door_closed", {
	description = "Magic Door",

	tiles = {
		"ccc_stone.png",
	},

	paramtype = "light",

	walkable = true,
	pointable = false,
	diggable = false,
})


core.register_node("ccc_core:magic_door_open", {
	description = "Open Magic Door",

	drawtype = "airlike",

	tiles = {
		"ccc_stone.png",
	},

	paramtype = "light",

	walkable = false,
	pointable = false,
	diggable = false,

	buildable_to = true,
})


core.register_abm({
	label = "Cursed Candle magic door",

	nodenames = {
		"ccc_core:magic_door_closed",
		"ccc_core:magic_door_open",
	},

	interval = CHECK_INTERVAL,
	chance = 1,

	action = function(pos)
		local node = core.get_node(pos)

		local candle_near =
			ccc.player_candle_near(pos)

		-- Player candle opens the door.
		if node.name == "ccc_core:magic_door_closed" then

			if candle_near then
				core.set_node(pos, {
					name = "ccc_core:magic_door_open",
				})
			end

		-- Moving away closes it again.
		elseif node.name == "ccc_core:magic_door_open" then

			if not candle_near then
				core.set_node(pos, {
					name = "ccc_core:magic_door_closed",
				})
			end
		end
	end,
})


ccc.doors = {}

function ccc.doors.set_open(pos, open)
	if open then
		core.set_node(pos, {
			name = "ccc_core:magic_door_open",
		})
	else
		core.set_node(pos, {
			name = "ccc_core:magic_door_closed",
		})
	end
end