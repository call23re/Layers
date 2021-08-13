local CollectionService = game:GetService("CollectionService")
local SelectionService = game:GetService("Selection")

local Plugin = script.Parent.Parent

local Constants = require(Plugin.Constants)
local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Button = StudioComponents.Button

local Move = Roact.Component:extend("Move")

function Move:init()
	self:setState({ Selection = SelectionService:Get() })

	self.onActivated = function()
		local targets = {}
		for _, instance in pairs(self.state.Selection) do
			local valid = false

			for _, baseType in pairs(Constants.ValidInstances) do
				if instance:IsA(baseType) then
					valid = true
					continue
				end
			end
	
			if valid then
				table.insert(targets, instance)
			end

		end
		self.props.BatchSetLayer(targets)
	end
end

function Move:didMount()
	self.selectionChanged = SelectionService.SelectionChanged:Connect(function()
		self:setState({ Selection = SelectionService:Get() })
	end)
end

function Move:willUnmount()
	self.selectionChanged:Disconnect()
end

function Move:render()
	local valid = false

	for _, instance in pairs(self.state.Selection) do

		for _, baseType in pairs(Constants.ValidInstances) do
			if instance:IsA(baseType) then
				valid = true
				continue
			end
		end

		if valid then
			continue
		end
	end

	return Roact.createElement(Button, {
		LayoutOrder = 3,
		Size = UDim2.new(0.3, -18, 1, 0),
		Text = "Move",
		Disabled = self.props.Disabled or not valid,
		OnActivated = self.onActivated,
	})
end

return Move