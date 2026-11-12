local PLAYER_CANDLE_RADIUS = 6.5

local function distance_squared(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z

	return dx * dx + dy * dy + dz * dz
end


local function has_line_of_sight(from_pos, to_pos)
	return core.line_of_sight(
		from_pos,
		to_pos,
		1
	)
end


function ccc.player_candle_near(pos)
	local players = core.get_connected_players()

	local max_distance_squared =
		PLAYER_CANDLE_RADIUS * PLAYER_CANDLE_RADIUS

	for _, player in ipairs(players) do
		local player_pos = player:get_pos()

		if distance_squared(pos, player_pos)
			<= max_distance_squared then

			local state = ccc.state_api.get(player)

			-- No flame if the player's wax is empty.
			if state and state.wax > 0 then
				-- The candle flame is above the player's feet.
				local flame_pos = {
					x = player_pos.x,
					y = player_pos.y + 1,
					z = player_pos.z,
				}

				if has_line_of_sight(pos, flame_pos) then
					return true
				end
			end
		end
	end

	return false
end