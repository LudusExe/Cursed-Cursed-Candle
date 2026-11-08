
local DRAIN_PER_SECOND = 0.20
local ACCUMULATOR = 0

local function set_wax(player, amount)
	local state = ccc.state_api.get(player)

	state.wax = ccc.util.clamp(amount, 0, state.max_wax)

	ccc.update_candle_visual(player, state.wax)
	ccc.hud_update(player)
end

function ccc.add_wax(player, amount)
	local state = ccc.state_api.get(player)
	set_wax(player, state.wax + amount)
end

function ccc.remove_wax(player, amount)
	local state = ccc.state_api.get(player)
	set_wax(player, state.wax - amount)
end

function ccc.get_wax(player)
	return ccc.state_api.get(player).wax
end

core.register_globalstep(function(dtime)
	ACCUMULATOR = ACCUMULATOR + dtime

	if ACCUMULATOR < 1 then
		return
	end

	local elapsed = ACCUMULATOR
	ACCUMULATOR = 0

	for _, player in ipairs(core.get_connected_players()) do
		local state = ccc.state_api.get(player)

		if not state.game_over then
			set_wax(
				player,
				state.wax - DRAIN_PER_SECOND * elapsed
			)

			if state.wax <= 0 then
				ccc.game_over(player)
			end
		end
	end
end)
