local ROOM_MIN = {x = -8, y = 0, z = -4}
local ROOM_MAX = {x = 8, y = 7, z = 12}
local SPAWN_POS = {x = 0, y = 2, z = 8}

local mod_storage = core.get_mod_storage()
local ROOM_INITIALIZED_KEY = "room_initialized"
local building_room = false

local function set_node(pos, name)
	core.set_node(pos, {name = name})
end

local function fill_box(minp, maxp, name)
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				set_node({x = x, y = y, z = z}, name)
			end
		end
	end
end

local function build_room()
	-- floor and ceiling
	fill_box(
		{x = ROOM_MIN.x, y = 0, z = ROOM_MIN.z},
		{x = ROOM_MAX.x, y = 0, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MIN.x, y = ROOM_MAX.y, z = ROOM_MIN.z},
		{x = ROOM_MAX.x, y = ROOM_MAX.y, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	-- Four walls.
	fill_box(
		{x = ROOM_MIN.x, y = 1, z = ROOM_MIN.z},
		{x = ROOM_MIN.x, y = ROOM_MAX.y - 1, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MAX.x, y = 1, z = ROOM_MIN.z},
		{x = ROOM_MAX.x, y = ROOM_MAX.y - 1, z = ROOM_MAX.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MIN.x + 1, y = 1, z = ROOM_MIN.z},
		{x = ROOM_MAX.x - 1, y = ROOM_MAX.y - 1, z = ROOM_MIN.z},
		"ccc_core:stone"
	)

	fill_box(
		{x = ROOM_MIN.x + 1, y = 1, z = ROOM_MAX.z},
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
		{x = -5, y = 2, z = 3},
		"ccc_core:candle"
	)

	set_node(
		{x = 5, y = 2, z = 3},
		"ccc_core:candle"
	)

	-- Spawn area.
	for x = -1, 1 do
		for z = 6, 8 do
			set_node({x = x, y = 1, z = z}, "air")
			set_node({x = x, y = 2, z = z}, "air")
			set_node({x = x, y = 3, z = z}, "air")
		end
	end

	mod_storage:set_string(ROOM_INITIALIZED_KEY, "true")
end

local function prepare_player(player)
	if not player or not player:is_player() then
		return
	end

	player:set_pos(SPAWN_POS)
end

local function ensure_room(player)
	if mod_storage:get_string(ROOM_INITIALIZED_KEY) == "true" then
		prepare_player(player)
		return
	end

	if building_room then
		return
	end

	building_room = true

	core.emerge_area(
		ROOM_MIN,
		ROOM_MAX,
		function(blockpos, action, calls_remaining, param)

			if calls_remaining ~= 0 then
				return
			end

			build_room()

			building_room = false

			prepare_player(player)
		end
	)
end

core.register_on_newplayer(function(player)
	ensure_room(player)
end)

core.register_on_joinplayer(function(player)
	ensure_room(player)
end)