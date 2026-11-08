local TORCH_LIGHT_RADIUS = 2.5
local TORCH_CHECK_INTERVAL = 0.2

local accumulator = 0

local function switch_torch(pos, lit)
	if lit then
		core.set_node(pos, {
			name = "ccc_core:torch_on",
		})
	else
		core.set_node(pos, {
			name = "ccc_core:torch_off",
		})
	end
end

local function toggle_torch(pos, node, player)
	if not player or not player:is_player() then
		return
	end

	if node.name == "ccc_core:torch_off" then
		switch_torch(pos, true)
		ccc.hud_message(player, "The torch catches fire.", 2)
	elseif node.name == "ccc_core:torch_on" then
		switch_torch(pos, false)
		ccc.hud_message(player, "The torch goes dark.", 2)
	end
end

local torch_definition = {
	description = "Torch",
	drawtype = "torchlike",
	tiles = {"ccc_candle_block.png"},

	paramtype = "light",
	paramtype2 = "wallmounted",

	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = false,

	groups = {
		not_in_creative_inventory = 1,
	},

	selection_box = {
		type = "wallmounted",
		wall_top = {-0.15, 0.35, -0.15, 0.15, 0.5, 0.15},
		wall_bottom = {-0.15, -0.5, -0.15, 0.15, -0.35, 0.15},
		wall_side = {-0.5, -0.15, -0.15, -0.35, 0.15, 0.15},
	},
}

core.register_node("ccc_core:torch_off", {
	description = "Torch (off)",

	drawtype = torch_definition.drawtype,
	tiles = torch_definition.tiles,
	paramtype = torch_definition.paramtype,
	paramtype2 = torch_definition.paramtype2,
	walkable = torch_definition.walkable,
	pointable = torch_definition.pointable,
	diggable = torch_definition.diggable,
	buildable_to = torch_definition.buildable_to,
	groups = torch_definition.groups,
	selection_box = torch_definition.selection_box,
	light_source = 0,

	on_rightclick = function(pos, node, clicker)
		toggle_torch(pos, node, clicker)
	end,
})

core.register_node("ccc_core:torch_on", {
	description = "Torch (on)",

	drawtype = torch_definition.drawtype,
	tiles = torch_definition.tiles,
	paramtype = torch_definition.paramtype,
	paramtype2 = torch_definition.paramtype2,
	walkable = torch_definition.walkable,
	pointable = torch_definition.pointable,
	diggable = torch_definition.diggable,
	buildable_to = torch_definition.buildable_to,
	groups = torch_definition.groups,
	selection_box = torch_definition.selection_box,
	light_source = 12,

	on_rightclick = function(pos, node, clicker)
		toggle_torch(pos, node, clicker)
	end,
})

local function can_be_ignited_by_player(player, torch_pos)
	local player_pos = player:get_pos()


	local flame_pos = {
		x = player_pos.x,
		y = player_pos.y + 1.0,
		z = player_pos.z,
	}

	local dx = flame_pos.x - torch_pos.x
	local dy = flame_pos.y - torch_pos.y
	local dz = flame_pos.z - torch_pos.z

	local distance = math.sqrt(
		dx * dx +
		dy * dy +
		dz * dz
	)

	if distance > TORCH_LIGHT_RADIUS then
		return false
	end
	return core.line_of_sight(flame_pos, torch_pos)
end

local function ignite_nearby_torches(player)
	local pos = player:get_pos()

	local min_pos = {
		x = math.floor(pos.x - TORCH_LIGHT_RADIUS),
		y = math.floor(pos.y - TORCH_LIGHT_RADIUS),
		z = math.floor(pos.z - TORCH_LIGHT_RADIUS),
	}

	local max_pos = {
		x = math.floor(pos.x + TORCH_LIGHT_RADIUS),
		y = math.floor(pos.y + TORCH_LIGHT_RADIUS),
		z = math.floor(pos.z + TORCH_LIGHT_RADIUS),
	}

	local torch_positions = core.find_nodes_in_area(
		min_pos,
		max_pos,
		{"ccc_core:torch_off"}
	)

	for _, torch_pos in ipairs(torch_positions) do
		if can_be_ignited_by_player(player, torch_pos) then
			switch_torch(torch_pos, true)
		end
	end
end

core.register_globalstep(function(dtime)
	accumulator = accumulator + dtime

	if accumulator < TORCH_CHECK_INTERVAL then
		return
	end

	accumulator = 0

	for _, player in ipairs(core.get_connected_players()) do
		local state = ccc.state_api.get(player)

		if not state.game_over then
			ignite_nearby_torches(player)
		end
	end
end)

core.sound_play("ccc_torch_ignite", {
	pos = pos,
	gain = 0.8,
	max_hear_distance = 8,
})

core.sound_play("ccc_torch_extinguish", {
	pos = pos,
	gain = 0.8,
	max_hear_distance = 8,
})