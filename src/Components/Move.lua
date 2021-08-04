local CollectionService = game:GetService("CollectionService")
local SelectionService = game:GetService("Selection")

local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Button = StudioComponents.Button

local Move = Roact.Component:extend("Move")

function Move:init()
	self:setState({ Selection = SelectionService:Get() })

	self.onActivated = function()
		local targets = {}
		for _, instance in ipairs(self.state.Selection) do
			if instance:IsA("BasePart") then
				table.insert(targets, instance)
			end
		end
		self.props.BatchSetLayer(targets)
	end
end

function Move:didMount()
	self.selectionChanged = SelectionService.SelectionChanged:connect(function()
		self:setState({ Selection = SelectionService:Get() })
	end)
end

function Move:willUnmount()
	self.selectionChanged:Disconnect()
end

function Move:render()
	local valid = false

	for _, instance in ipairs(self.state.Selection) do
		if not instance:IsA("BasePart") then
			continue
		elseif CollectionService:HasTag(instance, '_layered') then
			valid = true
			break
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