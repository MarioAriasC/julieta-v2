local utils = {}

function utils.ternary(cond, t, f)
	if cond then
		return t
	end
	return f
end

return utils
