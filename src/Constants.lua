return {
	MaxLayers = 1000,
	PluginActions = {
		NewLayer = {"new_layer", "New Layer", "Create a new layer."},
		RemoveLayer = {"remove_layer", "Remove Layer", "Removes selected layer."},
		MoveLayerUp = {"move_layer_up", "Move Layer Up", "Moves selected layer up."},
		MoveLayerDown = {"move_layer_down", "Move Layer Down", "Moves selected layer down."},
		MoveActiveUp = {"move_active_up", "Move Up", "Moves selection to upwards layer."},
		MoveActiveDown = {"move_active_down", "Move Down", "Moves selection to downwards layer."},
		GetSelection = {"get_selection", "Select Layer", "Selects all of the parts in the current layer."},
		MoveSelection = {"move_selection_to_layer", "Move Selection to Layer", "Moves selected parts to current layer."},
		ToggleVisibility = {"toggle_layer_visibility", "Toggle Layer Visibility", "Toggles current layers visibility."},
		ToggleLocked = {"toggle_layer_locked", "Toggle Layer Locked", "Toggles current layers lock."}
	}
}