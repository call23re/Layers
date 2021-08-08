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

local Actions = {
	NewLayer = plugin:CreatePluginAction("new_layer", "New Layer", "Create a new layer."),
	RemoveLayer = plugin:CreatePluginAction("remove_layer", "Remove Layer", "Removes selected layer."),
	MoveLayerUp = plugin:CreatePluginAction("move_layer_up", "Move Layer Up", "Moves selected layer up."),
	MoveLayerDown = plugin:CreatePluginAction("move_layer_down", "Move Layer Down", "Moves selected layer down."),
	MoveActiveUp = plugin:CreatePluginAction("move_active_up", "Move Up", "Moves selection to upwards layer."),
	MoveActiveDown = plugin:CreatePluginAction("move_active_down", "Move Down", "Moves selection to downwards layer."),
	GetSelection = plugin:CreatePluginAction("get_selection", "Select Layer", "Selects all of the parts in the current layer."),
	MoveSelection = plugin:CreatePluginAction("move_selection_to_layer", "Move Selection to Layer", "Moves selected parts to current layer."),
	ToggleVisibility = plugin:CreatePluginAction("toggle_layer_visibility", "Toggle Layer Visibility", "Toggles current layers visibility."),
	ToggleLocked = plugin:CreatePluginAction("toggle_layer_locked", "Toggle Layer Locked", "Toggles current layers lock."),
}

local main = Roact.createElement(MainPlugin, {
	Button = button,
	Actions = Actions
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