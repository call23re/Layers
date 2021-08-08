local Vendor = script.Parent.Parent.Parent.Vendor
local Roact = require(Vendor.Roact)

local Item = require(script.Parent.Item)

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		ItemA = Roact.createElement(Item, {
			Layer = {
				Id = 1,
				Name = "Layer 1"
			},
			Size = UDim2.new(0, 300, 0, 60),
			OnActivated = function() print("clicked") end
		}),
		ItemB = Roact.createElement(Item, {
			Layer = {
				Id = 2,
				Name = "Layer 2"
			},
			Size = UDim2.new(0, 300, 0, 60),
			OnActivated = function() print("clicked") end
		})
	})
	
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end