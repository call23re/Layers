local TextService = game:GetService("TextService")

local Vendor = script.Parent.Parent.Vendor

local Roact = require(Vendor.Roact)
local StudioComponents = require(Vendor.StudioComponents)

local Slider = require(script.Parent.Slider)
local Label = StudioComponents.Label
local TextInput = StudioComponents.TextInput

local ScaleSlider = Roact.Component:extend("ScaleSlider")

ScaleSlider.defaultProps = {
	Title = "Scale",
	onChanged = function() end
}

function ScaleSlider:init()
	self:setState({ value = self.props.value or 0 })

	self.updateValue = function(newValue)
		newValue = tonumber(newValue)

		if newValue == nil then
			return
		end

		if newValue > 1 or newValue < 0 then
			return
		end

		self:setState({ value = newValue })

		self.props.onChanged(newValue)
	end
end

function ScaleSlider:render()
	local labelSize = TextService:GetTextSize(self.props.Title, 14, Enum.Font.SourceSans, Vector2.new(200, 20))

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Position = self.props.Position
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Label = Roact.createElement(Label, {
			Size = UDim2.fromOffset(labelSize.X, 20),
			LayoutOrder = 0,
			Text = self.props.Title,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
		InputHolder = Roact.createElement("Frame", {
			Size = UDim2.new(0, 40, 0, 24),
			LayoutOrder = 1,
			BackgroundTransparency = 1,
		}, {
			Input = Roact.createElement(TextInput, {
				ClearTextOnFocus = false,
				PlaceholderText = "0",
				Text = self.state.value,
				OnChanged = self.updateValue
			}),
		}),
		Slider = Roact.createElement(Slider, {
			Size = UDim2.new(0, 200, 0, 20),
			LayoutOrder = 2,
			value = self.state.value,
			setValue = function(value)
				local mult = 10^2
  				value = math.floor(value * mult + 0.5) / mult
				self.updateValue(value)
			end
		})
	})
end

return ScaleSlider