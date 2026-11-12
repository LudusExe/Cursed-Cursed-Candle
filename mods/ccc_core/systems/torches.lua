-- Torch system.
--
-- Torches are controlled by the player's candle flame.
--
-- States:
--   ccc_core:torch_off
--   ccc_core:torch_on
--
-- Future puzzle systems can control them through:
--   ccc.torches.set_lit(pos, true)
--   ccc.torches.set_lit(pos, false)

ccc.torches = ccc.torches or {}

local IGNITE_RADIUS = 2.5
local CHECK_INTERVAL = 0.2

local accumulator = 0


local function play_sound(pos, sound_name)
	core.sound_play(sound_name, {
		pos = pos,
		gain = 0.8,
		max_hear_distance = 8,
	})
end


local function set_lit(pos, lit)
	local node = core.get_node_or_nil(pos)

	if not node then
		return false
	end

	local target_name

	if lit then
		target_name = "ccc_core:torch_on"
	else
		target_name = "ccc_core:torch_off"
	end

	if node.name == target_name then
		return false
	end

	if node.name ~= "ccc_core:torch_off"
		and node.name ~= "ccc_core:torch_on" then
		return false
	end

	core.set_node(pos, {
		name = target_name,
	})

	if lit then
		play_sound(pos, "ccc_torch_ignite")
	else
		play_sound(pos, "ccc_torch_extinguish")
	end

	return true
end


function ccc.torches.set_lit(pos, lit)
	return set_lit(pos, lit)
end


local selection_box = {
	type = "wallmounted",

	wall_top = {
		-0.15, 0.35, -0.15,
		 0.15, 0.5, 0.15,
	},

	wall_bottom = {
		-0.15, -0.5, -0.15,
		 0.15, -0.35, 0.15,
	},

	wall_side = {
		-0.5, -0.15, -0.15,
		-0.35, 0.15, 0.15,
	},
}


local groups = {
	not_in_creative_inventory = 1,
}


core.register_node("ccc_core:torch_off", {
	description = "Torch (off)",

	drawtype = "torchlike",

	tiles = {"ccc_candle_block.png"},

	paramtype = "light",
	paramtype2 = "wallmounted",

	light_source = 0,

	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false,

	groups = groups,

	selection_box = selection_box,
})


core.register_node("ccc_core:torch_on", {
	description = "Torch (on)",

	drawtype = "torchlike",

	tiles = {"ccc_candle_block.png"},

	paramtype = "light",
	paramtype2 = "wallmounted",

	light_source = 12,

	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false,

	groups = groups,

	selection_box = selection_box,
})


local function can_ignite(player, torch_pos)
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

	if distance > IGNITE_RADIUS then
		return false
	end

	local visible = core.line_of_sight(
		flame_pos,
		torch_pos
	)

	return visible
end


local function ignite_nearby_torches(player)
	local pos = player:get_pos()

	local min_pos = {
		x = math.floor(pos.x - IGNITE_RADIUS),
		y = math.floor(pos.y - IGNITE_RADIUS),
		z = math.floor(pos.z - IGNITE_RADIUS),
	}

	local max_pos = {
		x = math.floor(pos.x + IGNITE_RADIUS),
		y = math.floor(pos.y + IGNITE_RADIUS),
		z = math.floor(pos.z + IGNITE_RADIUS),
	}

	local torches = core.find_nodes_in_area(
		min_pos,
		max_pos,
		{"ccc_core:torch_off"}
	)

	for _, torch_pos in ipairs(torches) do
		if can_ignite(player, torch_pos) then
			set_lit(torch_pos, true)
		end
	end
end


core.register_globalstep(function(dtime)
	accumulator = accumulator + dtime

	if accumulator < CHECK_INTERVAL then
		return
	end

	accumulator = 0

	for _, player in ipairs(core.get_connected_players()) do
		ignite_nearby_torches(player)
	end
end)