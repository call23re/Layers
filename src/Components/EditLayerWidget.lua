local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Widget = StudioComponents.Widget
local Label = StudioComponents.Label
local TextInput = StudioComponents.TextInput
local Button = StudioComponents.Button
local MainButton = StudioComponents.MainButton
local ScaleSlider = require(script.Parent.ScaleSlider)

local LayerWidget = Roact.Component:extend("LayerWidget")

function LayerWidget:init()
	self:setState({
		LastText = self.props.LayerName,
		StartTransparency = self.props.Transparency,
		Transparency = self.props.Transparency or 0
	})

	self.setLastText = function(LastText)
		self:setState({ LastText = LastText })
	end

	self.setTransparency = function(transparency)
		self:setState({ Transparency = transparency })
		self.props.OnUpdate({ transparency = transparency })
	end
end

function LayerWidget:render()
	local lastText = self.state.LastText
	local layers = self.props.Layers

	local valid = true
	local message = nil
	if #lastText == 0 then
		valid = false
	elseif #lastText > 20 then
		valid = false
		message = "Name too long"
	else
		for _, group in ipairs(layers) do
			if group.name == lastText and group.name ~= self.props.LayerName then
				valid = false
				message = "Name already used"
				break
			end
		end
	end

	return Roact.createElement(Widget, {
		Id = "saveLayerWidget",
		Name = "saveLayerWidget",
		Title = self.props.Title,
		InitialDockState = Enum.InitialDockState.Float,
		MinimumWindowSize = Vector2.new(185, 85),
		OnClosed = self.props.OnClosed
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 7),
			PaddingRight = UDim.new(0, 7),
			PaddingTop = UDim.new(0, 7),
			PaddingBottom = UDim.new(0, 4),
		}),
		Label = Roact.createElement(Label, {
			Size = UDim2.fromOffset(31, 20),
			Text = "Name",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
		InputHolder = Roact.createElement("Frame", {
			Position = UDim2.fromOffset(38, 0),
			Size = UDim2.new(1, -38, 0, 20),
			BackgroundTransparency = 1,
		}, {
			Input = Roact.createElement(TextInput, {
				ClearTextOnFocus = false,
				PlaceholderText = "Enter name",
				Text = self.state.LastText,
				OnChanged = self.setLastText,
				OnFocusLost = function(enterPressed)
					if enterPressed and valid then
						self.props.OnSubmitted({
							name = lastText,
							transparency = self.state.Transparency
						})
					end
				end,
			}),
		}),
		Message = message and Roact.createElement(Label, {
			Position = UDim2.fromOffset(38, 21),
			Size = UDim2.new(1, -38, 0, 20),
			Text = message,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColorStyle = Enum.StudioStyleGuideColor.ErrorText,
		}),
		--[[Slider = Roact.createElement(ScaleSlider, {
			Position = UDim2.new(0, 0, 0, 54),
			Title = "Transparency",
			value = self.props.Transparency,
			onChanged = function(value)
				self.setTransparency(value)
			end
		}),
		Reset = Roact.createElement(Button, {
			Size = UDim2.new(0, 105, 0, 28),
			Position = UDim2.new(0, 0, 0, 85),
			Text = "Reset Transparency",
			OnActivated = function()
				self.setTransparency(self.state.StartTransparency)
				self.props.OnReset()
			end
		}),]]
		Buttons = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 4),
			}),
			SaveButton = Roact.createElement(MainButton, {
				LayoutOrder = 2,
				Size = UDim2.new(0, 65, 1, 0),
				Text = "Save",
				Disabled = not valid,
				OnActivated = function()
					self.props.OnSubmitted({ Name = lastText })
				end,
			}),
			CancelButton = Roact.createElement(Button, {
				LayoutOrder = 1,
				Size = UDim2.new(0, 65, 1, 0),
				Text = "Cancel",
				OnActivated = function()
					--self.setTransparency(self.state.StartTransparency)
					self.props.OnClosed()
				end,
			}),
		})
	})
end

return LayerWidget