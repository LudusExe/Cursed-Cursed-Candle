local CHECK_INTERVAL = 1


core.register_node("ccc_core:ice", {
	description = "Magic Ice",

	tiles = {
		"ccc_stone.png",
	},

	color = "#b8e6ff",

	paramtype = "light",

	walkable = true,
	pointable = false,
	diggable = false,
})


core.register_node("ccc_core:ice_melted", {
	description = "Melted Magic Ice",

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
	label = "Cursed Candle magic ice",

	nodenames = {
		"ccc_core:ice",
		"ccc_core:ice_melted",
	},

	interval = CHECK_INTERVAL,
	chance = 1,

	action = function(pos)
		local node = core.get_node(pos)

		local candle_near =
			ccc.player_candle_near(pos)

		if node.name == "ccc_core:ice" then

			if candle_near then
				core.set_node(pos, {
					name = "ccc_core:ice_melted",
				})
			end

		elseif node.name == "ccc_core:ice_melted" then

			if not candle_near then
				core.set_node(pos, {
					name = "ccc_core:ice",
				})
			end
		end
	end,
})