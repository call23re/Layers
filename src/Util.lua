local Constants = require(script.Parent.Constants)

local Util = {}

Util.ValidSelection = function(instances)
	for _, instance in pairs(instances) do
		for _, baseType in pairs(Constants.ValidInstances) do
			if instance:IsA(baseType) then
				return true
			end
		end
	end

	return false
end

return Util