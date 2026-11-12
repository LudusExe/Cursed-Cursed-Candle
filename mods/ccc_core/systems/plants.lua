local GROW_INTERVAL = 2

local function player_candle_near(pos)
	return ccc.player_candle_near(pos)
end


core.register_node("ccc_core:plant_seed", {
	description = "Plant Seed",

	drawtype = "nodebox",

	tiles = {
		"ccc_stone.png",
	},

	color = "#6fbf63",

	paramtype = "light",

	walkable = false,
	pointable = false,
	diggable = false,

	node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, -0.18, 0.18, -0.25, 0.18},
		},
	},
})


core.register_node("ccc_core:plant_growing", {
	description = "Growing Plant",

	drawtype = "plantlike",

	tiles = {
		"ccc_stone.png",
	},

	color = "#6fbf63",

	paramtype = "light",

	walkable = false,
	pointable = false,
	diggable = false,

	visual_scale = 0.8,
})


core.register_node("ccc_core:plant_grown", {
	description = "Grown Plant",

	drawtype = "nodebox",

	tiles = {
		"ccc_stone.png",
	},

	color = "#6fbf63",

	paramtype = "light",

	walkable = true,
	pointable = false,
	diggable = false,

	node_box = {
		type = "fixed",
		fixed = {
			-- Stem
			{-0.15, -0.5, -0.15, 0.15, 0.25, 0.15},

			-- Platform / leaves
			{-0.5, 0.20, -0.5, 0.5, 0.38, 0.5},
		},
	},
})


core.register_abm({
	label = "Cursed Candle plant growth",

	nodenames = {
		"ccc_core:plant_seed",
		"ccc_core:plant_growing",
		"ccc_core:plant_grown",
	},

	interval = GROW_INTERVAL,
	chance = 1,

	action = function(pos)
		local node = core.get_node(pos)
		local candle_near = player_candle_near(pos)

		-- Grow
		if candle_near then

			if node.name == "ccc_core:plant_seed" then
				core.set_node(pos, {
					name = "ccc_core:plant_growing",
				})

			elseif node.name == "ccc_core:plant_growing" then
				core.set_node(pos, {
					name = "ccc_core:plant_grown",
				})
			end

			return
		end

		-- Retract
		if node.name == "ccc_core:plant_grown" then
			core.set_node(pos, {
				name = "ccc_core:plant_growing",
			})

		elseif node.name == "ccc_core:plant_growing" then
			core.set_node(pos, {
				name = "ccc_core:plant_seed",
			})
		end
	end,
})