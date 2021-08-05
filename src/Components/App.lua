local Plugin = script.Parent.Parent
local Constants = require(Plugin.Constants)
local Layers = require(Plugin.Layers)

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Button = StudioComponents.Button
local MainButton = StudioComponents.MainButton
local List = require(script.Parent.List)
local Move = require(script.Parent.Move)
local CreateLayerWidget = require(script.Parent.CreateLayerWidget)
local DeleteLayerWidget = require(script.Parent.DeleteLayerWidget)
local EditLayerWidget = require(script.Parent.EditLayerWidget)

local App = Roact.Component:extend("App")

function App:init()

	self:setState({
		Layers = Layers.Layers,
		SelectedLayerId = 1,
		CreatingLayer = false,
		EditingLayer = false,
		DeletingLayer = false,
		MaxLayers = false
	})

	self.batchSetLayer = function(instances, id)
		Layers.addChildren(id, instances)
		self:update(id)
		self:setState({ Layers = Layers.Layers })
	end

	self.setLayer = function(instance, id)
		Layers.addChild(id, instance)
		self:update(id)
		self:setState({ Layers = Layers.Layers })
	end

	self.removeFromLayer = function(instance, id)
		Layers.removeChild(id, instance)
		self:update(id)
		self:setState({ Layers = Layers.Layers})
	end

	self.createLayer = function(name)
		local res = Layers.addLayer(name)
		if res then
			self:update(res)
			self:setState({ Layers = Layers.Layers })
			if res == Constants.MaxLayers then
				self:setState({ MaxLayers = true })
			end
		else
			warn(("Reached maximum number of layers (%s)."):format(Constants.MaxLayers))
		end
	end

	self.editLayer = function(id, newProperties)
		Layers.editLayer(id, newProperties)
	end

	self.deleteLayer = function(id)
		local res = Layers.removeLayer(id)
		if res then
			self:update(res)
			self:setState({
				MaxLayers = false,
				Layers = Layers.Layers
			})
		else
			warn(("Id %s does not exist."):format(id)) -- this should never happen anyway
		end
	end

	self.toggleVisibility = function(id)
		Layers.toggleVisibility(id)
		self:setState({ Layers = Layers.Layers })
	end

	self.toggleLock = function(id)
		Layers.toggleLock(id)
		self:setState({ Layers = Layers.Layers })
	end

	self.updateSelection = function()
		local children = Layers.Layers[self.state.SelectedLayerId].children
		local parts = {}

		for _, child in pairs(children) do
			table.insert(parts, child.part)
		end

		game.Selection:Set(parts)
	end

end

function App:update(id)
	self:setState({SelectedLayerId = id})
	Layers.setCurrentLayer(id)
end

function App:render()
	local isModalActive = self.state.CreatingLayer or self.state.DeletingLayer
	local selectedLayerName = self.state.Layers[self.state.SelectedLayerId].name
	local selectedLayerTransparency = self.state.Layers[self.state.SelectedLayerId].transparency

	return Roact.createFragment({
		CreateWidget = self.state.CreatingLayer and Roact.createElement(CreateLayerWidget, {
			Title = "Create Layer",
			Layers = self.state.Layers,
			OnClosed = function()
				self:setState({ CreatingLayer = false })
			end,
			OnSubmitted = function(name)
				self.createLayer(name)
				self:setState({ CreatingLayer = false })
			end
		}),
		DeleteWidget = self.state.DeletingLayer and Roact.createElement(DeleteLayerWidget, {
			Title = ("Delete Layer (%s"):format(selectedLayerName),
			LayerName = selectedLayerName,
			OnClosed = function()
				self:setState({ DeletingLayer = false })
			end,
			OnActivated = function()
				self.deleteLayer(self.state.SelectedLayerId)
				self:setState({ DeletingLayer = false })
			end
		}),
		EditWidget = self.state.EditingLayer and Roact.createElement(EditLayerWidget, {
			Title = ("Edit Layer (%s)"):format(selectedLayerName),
			Layers = self.state.Layers,
			LayerName = selectedLayerName,
			Transparency = selectedLayerTransparency,
			OnClosed = function()
				self:setState({ EditingLayer = false })
				Layers.resetTransparency(self.state.SelectedLayerId)
				self:update()
			end,
			OnUpdate = function(properties)
				self.editLayer(self.state.SelectedLayerId, properties)
				self:update()
			end,
			OnReset = function()
				Layers.resetTransparency(self.state.SelectedLayerId)
			end,
			OnSubmitted = function(properties)
				self.editLayer(self.state.SelectedLayerId, properties)
				self:setState({ EditingLayer = false })
				self:update()
			end
		}),
		UI = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 1, -5)
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
			List = Roact.createElement(List, {
				Layers = self.state.Layers,
				SelectedLayerId = self.state.SelectedLayerId,
				Disabled = isModalActive,
				Size = UDim2.new(1, 0, 1, -35),
				SetSelectedLayerId = function(id)
					self:update(id)
					if self.state.EditingLayer then
						self:setState({ EditingLayer = false })
						self:setState({ EditingLayer = true })
					end
				end,
				ToggleVisibility = function(id)
					self.toggleVisibility(id)
				end,
				ToggleLock = function(id)
					self.toggleLock(id)
				end
			}),
			Bar = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 6),
				}),
				Create = Roact.createElement(MainButton, {
					LayoutOrder = 0,
					Size = UDim2.new(0, 28, 1, 0),
					Text = "",
					OnActivated = function()
						self:setState({ CreatingLayer = true })
					end,
					Disabled = isModalActive or self.state.MaxLayers,
				}, {
					Icon = Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(16, 16),
						BackgroundTransparency = 1,
						Image = "rbxassetid://6688839343",
						ImageTransparency = (isModalActive or self.state.MaxLayers) and 0.75 or 0,
					}),
				}),
				Delete = Roact.createElement(Button, {
					LayoutOrder = 1,
					Size = UDim2.new(0, 28, 1, 0),
					Text = "",
					OnActivated = function()
						self:setState({ DeletingLayer = true })
					end,
					Disabled = self.state.SelectedLayerId == 1 or isModalActive
				}, {
					Icon = Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(32, 32),
						BackgroundTransparency = 1,
						Image = "rbxassetid://7203108940",
						ImageColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText),
						ImageTransparency = (self.state.SelectedLayerId == 1 or isModalActive) and 0.75 or 0,
					}),
				}),
				Edit = Roact.createElement(Button, {
					LayoutOrder = 2,
					Size = UDim2.new(0.3, -18, 1, 0),
					Text = "Edit",
					OnActivated = function()
						Layers.saveTransparency(self.state.SelectedLayerId)
						self:setState({ EditingLayer = true })
					end,
					Disabled = isModalActive
				}),
				Move = Roact.createElement(Move, {
					BatchSetLayer = function(targets)
						self.batchSetLayer(targets, self.state.SelectedLayerId)
					end
				}),
				Select = Roact.createElement(Button, {
					LayoutOrder = 4,
					Size = UDim2.new(0.3, -18, 1, 0),
					Text = "Select All",
					OnActivated = self.updateSelection,
					Disabled = isModalActive
				})
			})
		})
	})
end

return App