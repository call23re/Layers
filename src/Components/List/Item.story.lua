local Vendor = script.Parent.Parent.Parent.Vendor
local Roact = require(Vendor.Roact)

local Item = require(script.Parent.Item)

local layers = {}
local max = 5

for i = max, 1, -1 do
	table.insert(layers, Roact.createElement(Item, {
		NumLayers = max,
		Layer = {
			Id =i,
			Name = "Layer " .. i,
			Properties = {
				Visible = math.random() > 0.5,
				Locked = false
			}
		},
		Size = UDim2.new(0, 300, 0, 60),
		OnActivated = function() print("clicked") end
	}))
end

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		unpack(layers)
	})
	
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end