# Layers

Photoshop-like layering tool for building Roblox games.

<https://www.roblox.com/library/7203627668/Layers>

# Features
Add layers with the **"+"** button. Remove them with the **trash / bin** button.

Each layer has an **eye** button and a **lock** button. The eye button toggles visiblity. The lock button toggles the "Locked" property of every part in the layer.

The **Edit** button opens the edit widget, which allows you to change the name of the selected layer.

The **Move** button moves all of the parts in the current selection in to the currently selected layer.

The **Select All** button selects all of the parts in the currently selected layer.

The plugin adds a [PluginAction](https://developer.roblox.com/en-us/api-reference/class/PluginAction) for creating folders. To set up a keybind, go to File -> Advanced -> Customize Shortcuts, and search "make folder". I recommend overwriting ctrl + g.

Plugin has support for both dark and light themes.

# Screenshots
![img](https://i.imgur.com/aaQq2JK.png)
![img](https://i.imgur.com/vR3Y3Dq.png)

# Workflows
Using Sweetheartichoke's [Tag Editor plugin](https://www.roblox.com/library/948084095/Tag-Editor) makes it easier to distinguish between layers in the workspace.

The "Select All" tool combined with the _make folder_ PluginAction makes it easy to organize your workspace. Select Layer -> Select All -> ctrl + f -> rename -> repeat.


# todo
- layer rearranging
- layer merging

# Attribution
The code base is largely written on top of sircfenner's [Collision Groups Editor Plugin](https://devforum.community/t/collision-groups-editor-plugin/374). Many of the components used came from sircfenner's [Studio Components](https://github.com/sircfenner/StudioComponents).

Layer icon made by Freepik from flaticon.com
