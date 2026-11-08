local M = {}

function M.get(player)
	local name = player:get_player_name()
	if not ccc.state[name] then
		ccc.state[name] = {
			wax = 100,
			max_wax = 100,
			checkpoint = {x = 0, y = 2, z = 8},
			objective = "Find a way out",
			game_over = false,
			joined = false,
		}
	end
	return ccc.state[name]
end

function M.reset(player)
	local state = M.get(player)
	state.wax = state.max_wax
	state.game_over = false
	state.objective = "Find a way out"
	player:set_pos(state.checkpoint)
end

ccc.state_api = M
