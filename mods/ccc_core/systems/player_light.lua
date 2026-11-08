-- Luanti entities cannot directly emit block light, i use an invisible light node that follows the player

local player_lights = {}
local flame_entities = {}
local ACCUMULATOR = 0

local function light_pos(player)
	local p = player:get_pos()

	return {
		x = math.floor(p.x + 0.5),
		y = math.floor(p.y + 1.0),
		z = math.floor(p.z + 0.5),
	}
end

local function same_pos(a, b)
	return a and b
		and a.x == b.x
		and a.y == b.y
		and a.z == b.z
end

local function update_light(player)
	local name = player:get_player_name()
	local data = player_lights[name]
	local target = light_pos(player)

	if data and same_pos(data.pos, target) then
		return
	end

	if data and data.pos then
		local node = core.get_node_or_nil(data.pos)

		if node and node.name == "ccc_core:player_light" then
			core.set_node(data.pos, {name = "air"})
		end
	end

	local target_node = core.get_node_or_nil(target)

	if target_node and target_node.name == "air" then
		core.set_node(target, {
			name = "ccc_core:player_light"
		})

		player_lights[name] = {
			pos = target
		}
	else
		player_lights[name] = {
			pos = nil
		}
	end
end

local function spawn_flame(player)
	local name = player:get_player_name()

	if flame_entities[name]
		and flame_entities[name]:get_luaentity() then
		return
	end

	local p = player:get_pos()
	local flame = core.add_entity(p, "ccc_core:flame")

	if flame then
		flame:set_attach(
			player,
			"",
			{x = 0, y = 9, z = 0},
			{x = 0, y = 0, z = 0}
		)

		flame_entities[name] = flame
	end
end

core.register_entity("ccc_core:flame", {
	initial_properties = {
		physical = false,
		pointable = false,
		visual = "sprite",
		textures = {"ccc_flame.png"},
		visual_size = {
			x = 0.8,
			y = 0.8
		},
		glow = 12,
		static_save = false,
	},
})

core.register_on_joinplayer(function(player)
	spawn_flame(player)
	update_light(player)
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local data = player_lights[name]

	if data and data.pos then
		local node = core.get_node_or_nil(data.pos)

		if node and node.name == "ccc_core:player_light" then
			core.set_node(data.pos, {name = "air"})
		end
	end

	player_lights[name] = nil
	flame_entities[name] = nil
end)

core.register_globalstep(function(dtime)
	ACCUMULATOR = ACCUMULATOR + dtime

	if ACCUMULATOR < 0.1 then
		return
	end

	ACCUMULATOR = 0

	for _, player in ipairs(core.get_connected_players()) do
		update_light(player)
		spawn_flame(player)
	end
end)