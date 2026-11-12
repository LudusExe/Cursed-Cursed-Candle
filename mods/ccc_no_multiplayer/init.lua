local S = core.get_translator("ccc_no_multiplayer")

if not core.is_singleplayer() then
	error(S("This is not a multiplayer game! Please disable server hosting and try again."))
end