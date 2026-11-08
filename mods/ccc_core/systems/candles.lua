--the first reusable gameplay object

core.register_node("ccc_core:candle", {
	description = "Candle",
	tiles = {"ccc_candle_block.png"},
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	light_source = 10,
	walkable = true,
	paramtype = "light",

	on_rightclick = function(pos, node, clicker)
		if not clicker or not clicker:is_player() then
			return
		end

		local wax = ccc.get_wax(clicker)

		if wax >= 100 then
			ccc.hud_message(clicker, "Your wax is already full.", 2)
			return
		end

		ccc.add_wax(clicker, 25)
		ccc.hud_message(clicker, "The candle gives you some wax.", 2)
	end,
})