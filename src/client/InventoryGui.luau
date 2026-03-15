local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local InventoryGui = {}

function InventoryGui.init()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BackpackGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.new(0.2, 0, 0.4, 0)
	frame.Position = UDim2.new(0.02, 0, 0.3, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BackgroundTransparency = 0.5
	frame.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.1, 0)
	title.Text = "Backpack"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextScaled = true
	title.Parent = frame

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ItemList"
	scrollingFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
	scrollingFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.Parent = frame

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.Parent = scrollingFrame

	local function updateInventory()
		-- Clear existing items
		for _, child in ipairs(scrollingFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local items = {}

		-- Check Backpack
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			for _, item in ipairs(backpack:GetChildren()) do
				if item:IsA("Tool") then
					table.insert(items, item.Name)
				end
			end
		end

		-- Check Character (for equipped items)
		local character = player.Character
		if character then
			for _, item in ipairs(character:GetChildren()) do
				if item:IsA("Tool") then
					table.insert(items, item.Name .. " (Equipped)")
				end
			end
		end

		-- Create labels for items
		for _, itemName in ipairs(items) do
			local itemLabel = Instance.new("TextLabel")
			itemLabel.Size = UDim2.new(1, 0, 0, 30)
			itemLabel.Text = itemName
			itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			itemLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			itemLabel.BorderSizePixel = 0
			itemLabel.Parent = scrollingFrame
		end

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 35)
	end

	-- Listen for changes
	local function setupListeners(char)
		local backpack = player:WaitForChild("Backpack")
		
		backpack.ChildAdded:Connect(updateInventory)
		backpack.ChildRemoved:Connect(updateInventory)
		
		if char then
			char.ChildAdded:Connect(updateInventory)
			char.ChildRemoved:Connect(updateInventory)
		end
		
		updateInventory()
	end

	player.CharacterAdded:Connect(setupListeners)
	if player.Character then
		setupListeners(player.Character)
	end
end

return InventoryGui
