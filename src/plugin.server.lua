local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local Plugin = script.Parent

local Layers = require(script.Parent.Layers)
local Constants = require(script.Parent.Constants)
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

local Actions = {}

for actionName, action in pairs(Constants.PluginActions) do
	Actions[actionName] = plugin:CreatePluginAction(unpack(action))
end

local main = Roact.createElement(MainPlugin, {
	Button = button,
	Actions = Actions,
	OnEnabled = function(Enabled)
		Layers:SetEnabled(Enabled)
	end
})

local handle = Roact.mount(main, nil)

plugin.Unloading:Connect(function()
	Roact.unmount(handle)
	Layers:SetEnabled(false)
end)

settings().Studio.ThemeChanged:Connect(function()
	Roact.update(handle, main)
end)

plugin:CreatePluginAction("make_folder", "Make Folder", "Group the selected parts into a Folder.").Triggered:Connect(function()
	local currentSelection = Selection:Get()

	if #currentSelection > 0 then
		ChangeHistoryService:SetWaypoint("_makeFolder" .. tick())
		local folder = Instance.new("Folder")
		folder.Parent = workspace

		for _, object in pairs(currentSelection) do
			object.Parent = folder
		end

		Selection:Set({folder})
		ChangeHistoryService:SetWaypoint("_madeFolder" .. tick())
	end
end)