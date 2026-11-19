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

function utils.forEachIndexed(array, body)
	for k, v in pairs(array) do
		body(k, v)
	end
end

function utils.stacktrace_capture_with_return(body)
	local ok, final = xpcall(function()
		return body
	end, function(raw_error)
		return debug.traceback(raw_error, 2)
	end)

	if not ok then
		print(final)
		return nil
	else
		return final
	end
end

function utils.map(array, body)
	local t = {}
	for k, v in pairs(array) do
		t[k] = body(v)
	end
	return t
end

function utils.len(table)
	local i = 0
	for _k, _v in pairs(table) do
		i = i + 1
	end
	return i
end

return utils
