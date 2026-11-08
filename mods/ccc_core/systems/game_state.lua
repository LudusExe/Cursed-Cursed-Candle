function ccc.game_over(player)
	local state = ccc.state_api.get(player)
	if state.game_over then
		return
	end

	state.game_over = true
	state.objective = "Try again"
	ccc.hud_update(player)
	ccc.hud_message(player, "Your candle goes out. Back to the checkpoint...", 3)

	core.after(2.5, function()
		if not player or not player:is_player() then
			return
		end
		ccc.state_api.reset(player)
		ccc.hud_update(player)
		ccc.hud_message(player, "Your flame returns. Move quickly!", 3)
	end)
end

core.register_on_respawnplayer(function(player)
	ccc.state_api.reset(player)
	return true
end)
