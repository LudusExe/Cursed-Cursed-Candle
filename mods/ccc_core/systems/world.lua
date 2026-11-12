local ROOM_MIN = {
	x = -8,
	y = 0,
	z = -4,
}

local ROOM_MAX = {
	x = 8,
	y = 7,
	z = 12,
}

local SPAWN_POS = {
	x = 0,
	y = 2,
	z = 8,
}

-- La stanza è solo un ambiente di test.
-- Viene costruita una volta per avvio del mondo.
local room_initialized = false


local function set_node(pos, name)
	core.set_node(pos, {
		name = name,
	})
end


local function build_room()
	-- Floor
	for x = ROOM_MIN.x, ROOM_MAX.x do
		for z = ROOM_MIN.z, ROOM_MAX.z do
			set_node(
				{x = x, y = ROOM_MIN.y, z = z},
				"ccc_core:stone"
			)
		end
	end

	-- Ceiling
	for x = ROOM_MIN.x, ROOM_MAX.x do
		for z = ROOM_MIN.z, ROOM_MAX.z do
			set_node(
				{x = x, y = ROOM_MAX.y, z = z},
				"ccc_core:stone"
			)
		end
	end

	-- North wall
	for x = ROOM_MIN.x, ROOM_MAX.x do
		for y = ROOM_MIN.y + 1, ROOM_MAX.y - 1 do

			-- Door opening
			if not (
				x >= -1 and
				x <= 1 and
				y >= 1 and
				y <= 3
			) then
				set_node(
					{x = x, y = y, z = ROOM_MIN.z},
					"ccc_core:stone"
				)
			end

		end
	end

	-- South wall
	for x = ROOM_MIN.x, ROOM_MAX.x do
		for y = ROOM_MIN.y + 1, ROOM_MAX.y - 1 do
			set_node(
				{x = x, y = y, z = ROOM_MAX.z},
				"ccc_core:stone"
			)
		end
	end

	-- West / East walls
	for z = ROOM_MIN.z, ROOM_MAX.z do
		for y = ROOM_MIN.y + 1, ROOM_MAX.y - 1 do

			set_node(
				{x = ROOM_MIN.x, y = y, z = z},
				"ccc_core:stone"
			)

			set_node(
				{x = ROOM_MAX.x, y = y, z = z},
				"ccc_core:stone"
			)

		end
	end

	-- Existing candles
	set_node(
		{x = -5, y = 2, z = 3},
		"ccc_core:candle"
	)

	set_node(
		{x = 5, y = 2, z = 3},
		"ccc_core:candle"
	)

	-- Phase 2: torches
	set_node(
		{x = -5, y = 1, z = 1},
		"ccc_core:torch_off"
	)

	set_node(
		{x = 5, y = 1, z = 1},
		"ccc_core:torch_off"
	)

	-- Phase 3: plant
	set_node(
		{x = -2, y = 1, z = 2},
		"ccc_core:plant_seed"
	)

	-- Phase 3: ice
	set_node(
		{x = 2, y = 1, z = 2},
		"ccc_core:ice"
	)

	-- Phase 3: magic door
	-- Two blocks high
	set_node(
		{x = 0, y = 1, z = ROOM_MIN.z},
		"ccc_core:magic_door_closed"
	)

	set_node(
		{x = 0, y = 2, z = ROOM_MIN.z},
		"ccc_core:magic_door_closed"
	)

	-- Clear spawn area
	for x = -1, 1 do
		for y = 1, 3 do
			for z = 6, 10 do
				set_node(
					{x = x, y = y, z = z},
					"air"
				)
			end
		end
	end
end


local function initialize_world()
	if room_initialized then
		return
	end

	room_initialized = true

	build_room()

	core.emerge_area(
		ROOM_MIN,
		ROOM_MAX
	)

	local players = core.get_connected_players()

	for _, player in ipairs(players) do
		player:set_pos(SPAWN_POS)
	end
end


core.register_on_mods_loaded(function()
	core.after(1, initialize_world)
end)