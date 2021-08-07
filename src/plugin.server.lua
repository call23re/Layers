local Selection = game:GetService("Selection")

local Plugin = script.Parent

local Layers = require(script.Parent.Layers)
local Roact = require(Plugin.Vendor.Roact)
local MainPlugin = require(Plugin.Components.MainPlugin)

Layers:Init()

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


plugin:CreatePluginAction("make_folder", "Make Folder", "Group the selected parts into a Folder.").Triggered:Connect(function()
	local currentSelection = Selection:Get()

	if #currentSelection > 0 then
		local folder = Instance.new("Folder")
		folder.Parent = workspace

		for _, object in pairs(currentSelection) do
			object.Parent = folder
		end

		Selection:Set({folder})
	end
end)