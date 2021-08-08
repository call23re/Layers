local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Constants)

local MAX_LAYERS = Constants.MaxLayers
local TAG_FORMAT = "_layer_%s_%s"

local Layers = {
	Stack = {},
	Lookup = {},
	numberLayers = 0,
	currentLayer = 0
}

-- Private
function Layers:_UpdateStack()
	for index, layer in pairs(self.Stack) do
		layer.Id = index
		for _, child in pairs(layer.Children) do
			self:AddChild(index, child.Part)
		end
	end
	
	self.numberLayers = #self.Stack
	self.currentLayer = #self.Stack
end

function Layers:_SaveChildren(layerId)
	local layer = self.Stack[layerId]

	if layer then
		for instance, child in pairs(layer) do
			child.Properties.Anchored = instance.Anchored
			child.Properties.Locked = instance.Locked
			child.Properties.Transparency = instance.Transparency
		end
	end
end

function Layers:_UpdateTag(child)
	local layer = self.Stack[child.Id]

	for _, tag in pairs(CollectionService:GetTags(child.Part)) do
		if tag:find("_layer") then
			CollectionService:RemoveTag(child.Part, tag)
		end
	end

	CollectionService:AddTag(child.Part, "_layered")
	CollectionService:AddTag(child.Part, TAG_FORMAT:format(layer.Id, layer.Name))
end

function Layers:_UpdateChildren(layerId)
	local layer = self.Stack[layerId]
	
	if layer then
		ChangeHistoryService:SetWaypoint("_editLayers" .. tick())
		for instance, child in pairs(layer.Children) do

			if layer.Properties.Visible == false then
				child.Properties.Transparency = instance.Transparency
			else
				if instance.Transparency ~= 1 then
					child.Properties.Transparency = instance.Transparency
				end
			end
			
			instance.Locked = layer.Properties.Locked 
			instance.Transparency = (layer.Properties.Visible and child.Properties.Transparency or 1)
			--instance.Anchored = (layer.Properties.Visible and child.Properties.Anchored or true)

			self:_UpdateTag(child)
		end
		ChangeHistoryService:SetWaypoint("_editLayersFinished" .. tick())
	end
end

function Layers:_GetProperties(instance)
	local match = {"Anchored", "Locked", "Transparency"}
	local properties = {}
	
	for _, property in pairs(match) do
		properties[property] = instance[property]
	end
	
	return properties
end

-- Public
function Layers:AddChild(layerId, instance)
	
	-- only parts _for now_
	if not instance:IsA("BasePart") then
		return false
	end
	
	local layer = self.Stack[layerId]
	
	if layer then
		
		-- sanitize the instance
		if self.Lookup[instance] then
			self:RemoveChild(self.Lookup[instance].Id, instance)
		else
			self:ResetChild(instance)
		end
		
		local Child = {
			Id = layerId,
			Part = instance,
			Properties = self:_GetProperties(instance)
		}
		
		CollectionService:AddTag(instance, "_layered")
		CollectionService:AddTag(instance, TAG_FORMAT:format(layerId, layer.Name))
		
		instance.Locked = layer.Properties.Locked 
		instance.Transparency = (layer.Properties.Visible and instance.Transparency or 1)
		--instance.Anchored = (layer.Properties.Visible and instance.Anchored or true)
		
		layer.Children[instance] = Child
		self.Lookup[instance] = Child

		return self.numberLayers
		
	end
end

function Layers:RemoveChild(layerId, instance)
	local layer = self.Stack[layerId]
	
	if layer then
		self:ResetChild(instance)
		layer.Children[instance] = nil
	end
end

function Layers:ResetChild(instance)
	-- remove tags
	for _, tag in pairs(CollectionService:GetTags(instance)) do
		if tag:find("_layer") then
			CollectionService:RemoveTag(instance, tag)
		end
	end

	local Child = self.Lookup[instance]
	
	if Child then
		-- reset properties
		--instance.Anchored = Child.Properties.Anchored
		instance.Locked = Child.Properties.Locked
		instance.Transparency = Child.Properties.Transparency
		
		-- remove lookup
		self.Lookup[instance] = nil
	end
end

function Layers:AddChildren(layerId, children)
	local layer = self.Stack[layerId]

	if layer then
		for _, instance in pairs(children) do
			self:AddChild(layerId, instance)
		end
	end
end

function Layers:New(name)
	
	if self.numberLayers + 1 > MAX_LAYERS then
		return false
	end
	
	self.numberLayers = self.numberLayers + 1
	self.currentLayer = self.currentLayer + 1
	
	if not name then
		name = "Layer " .. self.numberLayers
	end
	
	local Layer = {
		Id = self.numberLayers,
		Name = name,
		Properties = {
			Visible = true,
			Locked = false
		},
		Children = {}
	}
	
	table.insert(self.Stack, Layer)
	
	return self.currentLayer
	
end

function Layers:Edit(layerId, newProperties)
	local layer = self.Stack[layerId]
	
	if layer then

		if newProperties["Name"] then
			layer.Name = newProperties.Name
		end

		for key, value in pairs(newProperties) do
			if layer.Properties[key] then
				layer.Properties[key] = value
			end
		end

		self:_UpdateChildren(layerId)
	end
end

function Layers:ToggleProperty(layerId, property)
	local layer = self.Stack[layerId]
	
	if layer then
		layer.Properties[property] = not layer.Properties[property]
		self:_UpdateChildren(layerId)
	end
end

function Layers:Remove(layerId)
	
	if self.numberLayers - 1 == 0 then
		return false
	end
	
	local layer = self.Stack[layerId]
	if layer then
		
		-- move children to the default layer
		for instance, child in pairs(layer.Children) do
			self:AddChild(1, instance)
		end
		
		-- remove the layer
		table.remove(self.Stack, layerId)
		
		-- update the stack
		self:_UpdateStack()

		return self.currentLayer

	end
	
end

function Layers:Move(layerId, direction)
	local newId = layerId + direction

	if newId <= 1 then
		return
	end

	-- only update if there's a layer to switch with
	if not self.Stack[newId] then
		return
	end

	local copy = unpack({self.Stack[newId]})
	self.Stack[newId] = self.Stack[layerId]
	self.Stack[layerId] = copy

	self:_UpdateStack()
	
end

function Layers:SetCurrentLayer(layerId)
	if self.Stack[layerId] then
		self.currentLayer = layerId
	end
end

function Layers:Init()
	if RunService:IsEdit() then
		self:New("Default")

		local tagged = CollectionService:GetTagged("_layered")
		local hashmap = {}
		local correspondingTagsMap = {}

		for _, object in pairs(tagged) do
			local tags = CollectionService:GetTags(object)
			for _, tag in pairs(tags) do
				if tag:find("layer_") then
					local data = tag:split("_")
					local id = tonumber(data[3])
					local name = data[4]

					if id == 1 and name == "Default" then
						self:AddChild(1, object)
						continue
					end

					-- prevent conflicting layers
					if hashmap[id] then
						if hashmap[id] ~= name then
							id = #hashmap + 1
						end
					end

					hashmap[id] = name
					if not correspondingTagsMap[id] then
						correspondingTagsMap[id] = {object}
					else
						table.insert(correspondingTagsMap[id], object)
					end
				end
			end
		end

		local sorted = {}
		local correspondingTags = {}
		local index = 1
		for id, name in pairs(hashmap) do
			index = index + 1
			sorted[index] = name
			correspondingTags[index] = correspondingTagsMap[id]
		end

		for id, name in pairs(sorted) do
			if id > 1 and id <= MAX_LAYERS then
				self:New(name)
			end

			local children = correspondingTags[id]
			self:AddChildren(id, children)
		end

		workspace.DescendantAdded:Connect(function(child)
			if child:IsA("BasePart") then
				self:AddChild(self.currentLayer, child)
			end
		end)

		-- if destroyed parts aren't removed, you get weird Selection related issues
		-- also keeping references to destroyed parts could potentially lead to memory leaks
		workspace.DescendantRemoving:Connect(function(child)
			if self.Lookup[child] then
				self:RemoveChild(self.Lookup[child].Id, child)
				self.Lookup[child] = nil
			end
		end)
	end
end

return Layers