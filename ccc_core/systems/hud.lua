
local hud_ids = {}
local last_wax_stage = {}
local last_objective = {}
local text_tokens = {}
local message_tokens = {}
local TEXT_DURATION = 10

local function get_wax_stage(percent)
	local stage = math.floor(percent / 5 + 0.5) * 5
	return ccc.util.clamp(stage, 0, 100)
end

local function ensure_hud(player)
	local name = player:get_player_name()

	if hud_ids[name] then
		return hud_ids[name]
	end

	local ids = {}

	ids.candle = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.02, y = 0.08},
		text = "ccc_candle_hud_100.png",
		alignment = {x = 0, y = 0},
		offset = {x = 0, y = 0},
		scale = {x = 1, y = 1},
	})

	ids.wax_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.02, y = 0.19},
		text = "",
		alignment = {x = 0, y = 0},
		offset = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		style = 1,
	})

	ids.objective = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.02, y = 0.24},
		text = "",
		alignment = {x = 0, y = 0},
		offset = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		style = 1,
	})

	ids.message = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0.82},
		text = "",
		alignment = {x = 0, y = 0},
		offset = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		style = 1,
	})

	hud_ids[name] = ids

	return ids
end

local function show_timed_text(player, element, text, key)
	local name = player:get_player_name()
	local ids = ensure_hud(player)

	text_tokens[name] = text_tokens[name] or {}
	text_tokens[name][key] = (text_tokens[name][key] or 0) + 1

	local token = text_tokens[name][key]

	player:hud_change(element, "text", text)

	core.after(TEXT_DURATION, function()
		if not player or not player:is_player() then
			return
		end

		if not hud_ids[name] then
			return
		end

		if text_tokens[name][key] ~= token then
			return
		end

		player:hud_change(element, "text", "")
	end)
end

function ccc.hud_update(player)
	local state = ccc.state_api.get(player)
	local ids = ensure_hud(player)

	local percent = 0

	if state.max_wax > 0 then
		percent = (state.wax / state.max_wax) * 100
	end

	percent = ccc.util.clamp(percent, 0, 100)

	local stage = get_wax_stage(percent)
	local name = player:get_player_name()

	-- changes texture every 5%
	if last_wax_stage[name] ~= stage then
		last_wax_stage[name] = stage

		local texture = string.format(
			"ccc_candle_hud_%03d.png",
			stage
		)

		player:hud_change(ids.candle, "text", texture)
		show_timed_text(
			player,
			ids.wax_text,
			string.format("%d%%", ccc.util.round(percent)),
			"wax"
		)
	end

	if last_objective[name] ~= state.objective then
		last_objective[name] = state.objective

		show_timed_text(
			player,
			ids.objective,
			"Objective: " .. state.objective,
			"objective"
		)
	end
end

function ccc.hud_message(player, text, duration)
	local ids = ensure_hud(player)
	local name = player:get_player_name()

	message_tokens[name] = (message_tokens[name] or 0) + 1
	local token = message_tokens[name]

	player:hud_change(ids.message, "text", text)

	core.after(duration or 3, function()
		if not player or not player:is_player() then
			return
		end

		if message_tokens[name] ~= token then
			return
		end

		player:hud_change(ids.message, "text", "")
	end)
end

core.register_on_joinplayer(function(player)
	-- Reset cached HUD state for this session.
	local name = player:get_player_name()

	last_wax_stage[name] = nil
	last_objective[name] = nil

	ccc.hud_update(player)

	ccc.hud_message(
		player,
		"You wake up in a strange room...",
		4
	)
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	hud_ids[name] = nil
	last_wax_stage[name] = nil
	last_objective[name] = nil
	text_tokens[name] = nil
	message_tokens[name] = nil
end)
