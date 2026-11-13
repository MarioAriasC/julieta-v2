local utils = {}

function utils.ternary(cond, t, f)
	if cond then
		return t
	end
	return f
end

function utils.forEach(array, body)
	for i = 1, #array do
		body(array[i])
	end
end

return utils
