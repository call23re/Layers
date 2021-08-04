local Selection = game:GetService("Selection")

local Plugin = script.Parent

local Roact = require(Plugin.Vendor.Roact)
local MainPlugin = require(Plugin.Components.MainPlugin)

local toolbar = plugin:CreateToolbar("Layers")
local button = toolbar:CreateButton(
	"Layers",
	"Layers",
	"rbxassetid://7203255268"
)
button.ClickableWhenViewportHidden = true

local main = Roact.createElement(MainPlugin, {
	Button = button,
})

local handle = Roact.mount(main, nil)

plugin.Unloading:Connect(function()
	Roact.unmount(handle)
end)

settings().Studio.ThemeChanged:connect(function()
	Roact.update(handle, main)
end)


plugin:CreatePluginAction("make_folder", "Make folder", "Group the selected parts into a Folder").Triggered:connect(function()
	local f = Instance.new("Folder")
	f.Parent = workspace
	for _, o in pairs(Selection:Get()) do
		o.Parent = f
	end
	Selection:Set({f})
end)