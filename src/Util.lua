local CollectionService = game:GetService("CollectionService")

local Constants = require(script.Parent.Constants)

local Util = {}

Util.ValidSelection = function(instances)
	for _, instance in pairs(instances) do

		if CollectionService:HasTag(instance, "_ignorelayers") then
			return false
		end

		if instance.Name == "ToolboxTemporaryInsertModel" then
			return false
		end

		-- It is not unusual for plugins to store visual indicators in the camera. This plugin tends to interfere with them.
		if instance:IsDescendantOf(workspace.Camera) then
			return false
		end

		for _, baseType in pairs(Constants.ValidInstances) do
			if instance:IsA(baseType) then
				return true
			end
		end
	end

	return false
end

return Util