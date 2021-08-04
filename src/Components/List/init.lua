local Plugin = script.Parent.Parent
local Constants = require(Plugin.Constants)

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local ScrollFrame = StudioComponents.ScrollFrame
local Item = require(script.Item)

local function List(props)
	local children = {}

	for _, layer in pairs(props.Layers) do
		table.insert(
			children,
			Roact.createElement(Item, {
				Layer = layer,
				SelectedLayer = (layer.id == props.SelectedLayerId),
				Opacity = layer.transparency,
				LayoutOrder = (Constants.MaxLayers - layer.id),
				OnActivated = function()
					if not props.Disabled then
						props.SetSelectedLayerId(layer.id)
					end
				end,
				OnVisibilityToggled = function()
					if not props.Disabled then
						props.ToggleVisibility(layer.id)
					end
				end,
				OnLockToggled = function()
					if not props.Disabled then
						props.ToggleLock(layer.id)
					end
				end,
				Disabled = props.Disabled
			})
		)
	end

	return Roact.createFragment({
		Frame = Roact.createElement(ScrollFrame, {
			Size = props.Size or UDim2.new(1, 0, 1, 0),
			Disabled = props.Disabled
		}, children)
	})
end

return List