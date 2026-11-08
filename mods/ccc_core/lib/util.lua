local M = {}

function M.clamp(value, min_value, max_value)
	return math.max(min_value, math.min(max_value, value))
end

function M.round(value)
	return math.floor(value + 0.5)
end

function M.distance(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function M.copy_pos(pos)
	return {x = pos.x, y = pos.y, z = pos.z}
end

ccc.util = M
