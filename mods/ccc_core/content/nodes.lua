core.register_node("ccc_core:stone", {
	description = "Room Stone",
	tiles = {"ccc_stone.png"},
	groups = {cracky = 3, not_in_creative_inventory = 1},
	is_ground_content = false,
})

core.register_node("ccc_core:player_light", {
	description = "Candlelight",
	drawtype = "airlike",
	paramtype = "light",
	light_source = 12,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	groups = {not_in_creative_inventory = 1},
})

core.register_node("ccc_core:mapgen_stone", {
	description = "Mapgen Stone",
	tiles = {"ccc_stone.png"},
	groups = {
		cracky = 3,
		not_in_creative_inventory = 1,
	},
})

core.register_node("ccc_core:mapgen_water_source", {
	description = "Mapgen Water",
	drawtype = "liquid",
	tiles = {
		{
			name = "ccc_water.png",
			backface_culling = false,
		},
	},
	paramtype = "light",
	liquidtype = "source",
	liquid_alternative_flowing = "ccc_core:mapgen_water_source",
	liquid_alternative_source = "ccc_core:mapgen_water_source",
	liquid_viscosity = 1,
	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	groups = {
		water = 3,
		not_in_creative_inventory = 1,
	},
})
core.register_alias("mapgen_stone", "ccc_core:mapgen_stone")
core.register_alias(
	"mapgen_water_source",
	"ccc_core:mapgen_water_source"
)