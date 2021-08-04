local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Widget = StudioComponents.Widget
local App = require(Plugin.Components.App)

local MainPlugin = Roact.Component:extend("MainPlugin")

function MainPlugin:init()
	self:setEnabled(false)
end

function MainPlugin:setEnabled(enabled)
	self:setState({ Enabled = enabled })
	self.props.Button:SetActive(enabled)
end

function MainPlugin:didMount()
	self.buttonClicked = self.props.Button.Click:Connect(function()
		self:setEnabled(not self.state.Enabled)
	end)
end

function MainPlugin:willUnmount()
	self.buttonClicked:Disconnect()
end

function MainPlugin:render()
	return self.state.Enabled and Roact.createElement(Widget, {
		Id = "layersWidget",
		Name = "layersWidget",
		Title = "Layers",
		InitialDockState = Enum.InitialDockState.Float,
		MinimumWindowSize = Vector2.new(300, 200),
		OnClosed = function()
			self:setEnabled(false)
		end,
	}, {
		App = Roact.createElement(App),
	})
end

return MainPlugin