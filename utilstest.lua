local utils = require("utils")

local utiltests = {}

function utiltests.forEachTests(array, size, body)
	if size == 2 then
		utils.forEach(array, function(entry)
			body(entry[1], entry[2])
		end)
	elseif size == 3 then
		utils.forEach(array, function(entry)
			body(entry[1], entry[2], entry[3])
		end)
	elseif size == 4 then
		utils.forEach(array, function(entry)
			body(entry[1], entry[2], entry[3], entry[4])
		end)
	end
end

return utiltests
