local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local withTheme = StudioComponents.withTheme

local Item = Roact.Component:extend("Item")

function Item:init()
	self:setState({
		Active = true,
		Hover = false,
		Visible = true,
		Locked = false
	})

	self.onInputBegan = function(_, input)
		if self.props.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end

	self.onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end

	self.toggleVisibility = function()
		if self.props.Disabled then
			return
		end
		self:setState({ Visible = not self.state.Visible })
	end

	self.toggleLock = function()
		if self.props.Disabled then
			return
		end
		self:setState({ Locked = not self.state.Locked })
	end
end

function Item:render()

	local color = Enum.StudioStyleGuideColor.FilterButtonDefault
	if self.props.Selected then
		color = Enum.StudioStyleGuideColor.FilterButtonChecked
	elseif self.state.Hover then
		color = Enum.StudioStyleGuideColor.FilterButtonHover
	elseif self.props.SelectedLayer then
		color = settings().Studio.Theme.Name == "Dark" and Enum.StudioStyleGuideColor.Button or Enum.StudioStyleGuideColor.MainButton
	end

	return withTheme(function(theme)

		local modifier = Enum.StudioStyleGuideModifier.Default
		if self.props.Disabled then
			modifier = Enum.StudioStyleGuideModifier.Disabled
		end

		local lockIcon = self.state.Locked and "rbxassetid://7199980830" or "rbxassetid://7199980066"
		local visibleIcon = self.state.Visible and "rbxassetid://7199979125" or "rbxassetid://7199979548"

		return Roact.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(color, modifier),
			BorderSizePixel = 1,
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
			LayoutOrder = self.props.LayoutOrder,
			Size = self.props.Size or UDim2.new(1, 0, 0, 60)
		}, {
			Button = Roact.createElement("TextButton", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 60, 0, 5),
				Size = UDim2.new(1, -120, 1, 0),
				Text = "",
				[Roact.Event.MouseButton1Click] = self.props.OnActivated
			}),
			LayerLabel = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.ArialBold,
				Position = UDim2.new(0, 75, 0, 10),
				Size = UDim2.new(1, -75, 0, 20),
				Text = self.props.Layer.name,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top
			}),
			TransparencyLabel = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Arial,
				Position = UDim2.new(0, 75, 0, 30),
				Size = UDim2.new(1, -75, 0, 20),
				Text = (100 - (self.props.Opacity * 100)) .. "%",
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top
			}),
			Visible = Roact.createElement("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = theme:GetColor(color, modifier),
				BorderSizePixel = 1,
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
				Size = UDim2.new(0, 60, 0, 60),
				Text = "",
				[Roact.Event.MouseButton1Click] = function()
					self.toggleVisibility()
					self.props.OnVisibilityToggled()
				end
			}, {
				Img = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = visibleIcon,
					ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.new(0, 25, 0, 25),
				}),
			}),
			Lock = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = lockIcon,
				ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
				Position = UDim2.new(1, - 40, 0.5, 0),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.new(0, 20, 0, 20),
				[Roact.Event.MouseButton1Click] = function()
					self.toggleLock()
					self.props.OnLockToggled()
				end
			})
		})
	end)
end

return Item