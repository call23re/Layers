# Layers

Layering tool for manipulating and visualizing sections of Roblox builds.

<https://www.roblox.com/library/7203627668/Layers>

This plugin is in beta. There are probably some bugs I didn't catch. There are also some features I haven't implemented yet. Feedback is welcome!

# Features
Functionality is very similar to layering in most image editing software.
- Each layer can be hidden and locked.
- Layers can be rearranged, edited, and removed.
- You can move parts between layers.
- You can select every part within a given layer.

# Shortcuts
The plugin adds the following shortcuts to Roblox Studio:
- Make Folder
- New Layer
- Remove Layer
- Layer Up
- Layer Down
- Move Up
- Move Down
- Select Layer
- Move Selection to Layer
- Toggle Layer Visibility
- Toggle Layer Locked

None of these are bound to anything by default. To set keybinds go to File -> Advanced -> Customize Shortcuts, and search for any of the listed shortcuts. All of the functionality above is available through the interface as well.

# Workflows
Using Sweetheartichoke's [Tag Editor plugin](https://www.roblox.com/library/948084095/Tag-Editor) makes it easier to distinguish between layers in the workspace.

The plugin creates a folder in ServerStorage called "_layers". Don't delete this folder. If you're using Rojo, set `$ignoreUnknownInstances` in ServerStorage to true or add the folder to your project json.

The _Select All_ tool / keybind combined with the _Make Folder_ shortcut makes it easy to organize your workspace. Select Layer -> _Select All_ -> _Make Folder_ -> Rename -> Repeat.

# Attribution
The code base is largely written on top of sircfenner's [Collision Groups Editor Plugin](https://github.com/sircfenner/CollisionGroupsEditor). Many of the components used came from sircfenner's [Studio Components](https://github.com/sircfenner/StudioComponents) repo.

Layer icon made by Freepik from flaticon.com