local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Constants)

local Layers = {}
local lookup = {}

local numLayers = 0
local maxLayers = Constants.MaxLayers
local currentLayer = 1

local function setCurrentLayer(id)
	currentLayer = id
end

local function removeChild(child)
	if typeof(child) ~= "table" then
		child = lookup[child]
	end

	local layer = Layers[child.id]

	pcall(function()
		CollectionService:RemoveTag(child.part, "_layered")
		CollectionService:RemoveTag(child.part, string.format("_layer_%s_%s", child.id, layer.name))
		child.part.Transparency = child.transparency
		child.part.Locked = child.locked
	end)

	Layers[child.id].children[child.part] = nil
	lookup[child.part] = nil
end

local function addChild(id, child)
	local layer = Layers[id]
	if layer then
		if lookup[child] then
			removeChild(child)
		end

		local tags = CollectionService:GetTags(child)
		for _, tag in pairs(tags) do
			if tag:find("layer_") then
				CollectionService:RemoveTag(child, tag)
			end
		end

		CollectionService:AddTag(child, "_layered")
		CollectionService:AddTag(child, string.format("_layer_%s_%s", id, layer.name))
		layer.children[child] = {id = id, part = child, transparency = child.Transparency, locked = child.Locked}
		--child.Transparency = layer.transparency
		--child.Locked = layer.Locked
		lookup[child] = layer.children[child]
	end
end

local function addChildren(id, children)
	if Layers[id] then
		for _, child in pairs(children) do
			addChild(id, typeof(child) == "table" and child.part or child)
		end
	end
end

local function removeChildren(children)
	for _, child in pairs(children) do
		removeChild(child)
	end
end

local function update()
	for i, v in pairs(Layers) do
		v.id = i
	end
	numLayers = #Layers
end

local function addLayer(name)

	if numLayers + 1 > maxLayers then
		return false
	end

	if not name then
		name = numLayers + 1
	end

	numLayers = numLayers + 1

	local data = {
		id = numLayers,
		name = name,
		visible = true,
		locked = false,
		transparency = 0,
		children = {}
	}

	Layers[numLayers] = data

	return numLayers

end

local function updateTransparency(id)
	--ChangeHistoryService:SetWaypoint(string.format("PreUpdateTransparency%s%s", id, math.random()))
	local layer = Layers[id]
	if layer then
		for _, child in pairs(layer.children) do
			child.part.Transparency = layer.transparency
		end
	end
	--ChangeHistoryService:SetWaypoint(string.format("PostUpdateTransparency%s%s", id, math.random()))
end

local function saveTransparency(id)
	local layer = Layers[id]
	if layer then
		for _, child in pairs(layer.children) do
			child.transparency = child.part.Transparency
		end
	end
end

local function resetTransparency(id)
	local layer = Layers[id]
	if layer then
		for _, child in pairs(layer.children) do
			child.part.Transparency = child.transparency
		end
		layer.transparency = 0
	end
end

local function editLayer(id, newProperties)
	local layer = Layers[id]

	if layer then
		for key, value in pairs(newProperties) do
			layer[key] = value
		end

		if newProperties.name then
			addChildren(id, layer.children)
		end
	end

	if newProperties.transparency then
		updateTransparency(id)
	end
end

local function toggleVisibility(id)
	local layer = Layers[id]
	if layer then
		layer.visible = not layer.visible
		if layer.visible then
			for _, child in pairs(layer.children) do
				if child.part:IsA("BasePart") then
					-- if the transparency was manually changed since it was set to invisible, set its new default transparency to its current transparency
					if child.part.Transparency ~= 1 and child.part.Transparency ~= child.transparency then
						child.transparency = child.part.Transparency
					end
					child.part.Transparency = child.transparency
				end
			end
		else
			for _, child in pairs(layer.children) do
				if child.part:IsA("BasePart") then
					child.transparency = child.part.Transparency
					child.part.Transparency = 1
				end
			end
		end
	end
end

local function toggleLock(id)
	local layer = Layers[id]
	if layer then
		layer.locked = not layer.locked
		if not layer.locked then
			for _, child in pairs(layer.children) do
				if child.part:IsA("BasePart") then
					child.part.Locked = child.locked
				end
			end
		else
			for _, child in pairs(layer.children) do
				if child.part:IsA("BasePart") then
					child.locked = child.part.Locked
					child.part.Locked = true
				end
			end
		end
	end
end

local function removeLayer(id)

	if numLayers - 1 == 0 then
		return false
	end

	if Layers[id] then
		local copy = {}

		for _, child in pairs(Layers[id].children) do
			table.insert(copy, child.part)
		end

		removeChildren(Layers[id].children)
		table.remove(Layers, id)
		update()
		addChildren(1, copy)
		return numLayers
	end

	return false
end

-- init
if RunService:IsEdit() then
	addLayer("Default")

	local tagged = CollectionService:GetTagged("_layered")
	local sorted = {}
	local correspondingTags = {}

	for _, object in pairs(tagged) do
		local tags = CollectionService:GetTags(object)
		for _, tag in pairs(tags) do
			if tag:find("layer_") then
				local data = tag:split("_")
				local id = tonumber(data[3])
				local name = data[4]
				sorted[id] = name
				if not correspondingTags[id] then
					correspondingTags[id] = {object}
				else
					table.insert(correspondingTags[id], object)
				end
			end
		end
	end

	for id, name in pairs(sorted) do
		if id > 1 and id <= maxLayers then
			addLayer(name)
		end

		local children = correspondingTags[id]
		addChildren(id, children)
	end

	workspace.DescendantAdded:connect(function(child)
		if child:IsA("BasePart") then
			addChild(currentLayer, child)
		end
	end)
end

return {
	Layers = Layers,
	setCurrentLayer = setCurrentLayer,
	addLayer = addLayer,
	removeLayer = removeLayer,
	editLayer = editLayer,
	addChild = addChild,
	removeChild = removeChild,
	addChildren = addChildren,
	removeChildren = removeChildren,
	toggleVisibility = toggleVisibility,
	toggleLock = toggleLock,
	saveTransparency = saveTransparency,
	resetTransparency = resetTransparency
}