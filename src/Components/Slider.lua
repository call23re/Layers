-- based off of https://github.com/tiffany352/RoactStudioWidgets/blob/master/lib/Slider.lua

local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local withTheme = StudioComponents.withTheme

local Slider = Roact.PureComponent:extend("Slider")

-- props:
-- float value
-- void setValue(float)
function Slider:render()
	local props = self.props

	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			AutoButtonColor = false,
			Size = props.Size,
			Position = props.Position or UDim2.new(0, 0, 0, 0),
			LayoutOrder = props.LayoutOrder,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
			Text = "",

			[Roact.Event.InputBegan] = function(rbx, input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					self.startPos = input.Position
					self:setState({
						pressed = true,
					})
					local mousePos = Vector2.new(
						input.Position.X,
						input.Position.Y
					)
					local value = (mousePos - rbx.AbsolutePosition) / rbx.AbsoluteSize
					if props.setValue then
						props.setValue(value.X)
					end
				end
			end,
			
			[Roact.Event.InputChanged] = function(rbx, input)
				if self.startPos and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mousePos = Vector2.new(
						input.Position.X,
						input.Position.Y
					)
					local value = (mousePos - rbx.AbsolutePosition) / rbx.AbsoluteSize
					if props.setValue then
						props.setValue(value.X)
					end
				end
			end,

			[Roact.Event.InputEnded] = function(rbx, input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					self.startPos = nil
					self:setState({
						pressed = false,
					})
				end
			end,
		}, {
			Bar = Roact.createElement("Frame", {
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, -20, 0, 2),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScriptRuler),
				BorderSizePixel = 0
			}, {
				Fill = Roact.createElement("Frame", {
					Position = UDim2.new(props.value or 0, props.value > 0.9 and -8 or 0, 0, -9),
					Size = UDim2.new(0, 8, 0, 20),
					--BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button),
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.GameSettingsTooltip),
					BorderSizePixel = 0
				}),
			})
		})
	end)
end

return Slider