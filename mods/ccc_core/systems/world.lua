local ROOM_MIN = {x = -8, y = 0, z = -4}
local ROOM_MAX = {x = 8, y = 7, z = 12}
local SPAWN_POS = {x = 0, y = 2, z = 8}
local mod_storage = core.get_mod_storage()
local ROOM_VERSION = "2"

local ROOM_VERSION_KEY = "room_version"

local building_room = false
local waiting_player = nil


local function set_node(pos, name)
	core.set_node(pos, {
		name = name,
	})
end


local function fill_box(minp, maxp, name)
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				set_node(
					{x = x, y = y, z = z},
					name
				)
			end
		end
	end
end


local function clear_room_interior()
	fill_box(
		{x = ROOM_MIN.x + 1, y = ROOM_MIN.y + 1, z = ROOM_MIN.z + 1},
		{x = ROOM_MAX.x - 1, y = ROOM_MAX.y - 1, z = ROOM_MAX.z - 1},
		"air"
	)
end


local function build_room()
	clear_room_interior()

	fill_box(
		{x = ROOM_MIN.x, y = ROOM_MIN.y, z = ROOM_MIN.z},
		{x = ROOM_MAX.x, y = ROOM_MIN.y, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MIN.x, y = ROOM_MAX.y, z = ROOM_MIN.z},
		{x = ROOM_MAX.x, y = ROOM_MAX.y, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MIN.x, y = ROOM_MIN.y + 1, z = ROOM_MIN.z},
		{x = ROOM_MIN.x, y = ROOM_MAX.y - 1, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MAX.x, y = ROOM_MIN.y + 1, z = ROOM_MIN.z},
		{x = ROOM_MAX.x, y = ROOM_MAX.y - 1, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MIN.x + 1, y = ROOM_MIN.y + 1, z = ROOM_MIN.z},
		{x = ROOM_MAX.x - 1, y = ROOM_MAX.y - 1, z = ROOM_MIN.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MIN.x + 1, y = ROOM_MIN.y + 1, z = ROOM_MAX.z},
		{x = ROOM_MAX.x - 1, y = ROOM_MAX.y - 1, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	for x = -1, 1 do
		for y = 1, 3 do
			set_node(
				{x = x, y = y, z = ROOM_MIN.z},
				"air"
			)
		end
	end

	set_node(
		{x = -5, y = 1, z = 3},
		"ccc_core:candle"
	)

	set_node(
		{x = 5, y = 1, z = 3},
		"ccc_core:candle"
	)

	if core.registered_nodes["ccc_core:torch_off"] then
		set_node(
			{x = -5, y = 1, z = 1},
			"ccc_core:torch_off"
		)

		set_node(
			{x = 5, y = 1, z = 1},
			"ccc_core:torch_off"
		)

		set_node(
			{x = -5, y = 1, z = 6},
			"ccc_core:torch_off"
		)

		set_node(
			{x = 5, y = 1, z = 6},
			"ccc_core:torch_off"
		)
	end

	mod_storage:set_string(
		ROOM_VERSION_KEY,
		ROOM_VERSION
	)
end


local function prepare_player(player)
	if not player or not player:is_player() then
		return
	end
	player:set_pos(SPAWN_POS)

	local state = ccc.state_api.get(player)

	state.checkpoint = {
		x = SPAWN_POS.x,
		y = SPAWN_POS.y,
		z = SPAWN_POS.z,
	}
end


local function room_is_current()
	return mod_storage:get_string(ROOM_VERSION_KEY) == ROOM_VERSION
end


local function ensure_room(player)
	if not player or not player:is_player() then
		return
	end

	if room_is_current() then
		prepare_player(player)
		return
	end

	if building_room then
		waiting_player = player
		return
	end

	building_room = true
	waiting_player = player
	core.emerge_area(
		ROOM_MIN,
		ROOM_MAX,
		function(blockpos, action, calls_remaining, param)

			if calls_remaining ~= 0 then
				return
			end

			build_room()

			building_room = false

			if waiting_player
				and waiting_player:is_player() then

				prepare_player(waiting_player)
			end

			waiting_player = nil
		end
	)
end


core.register_on_joinplayer(function(player)
	ensure_room(player)
end)


core.register_on_newplayer(function(player)
	ensure_room(player)
end)