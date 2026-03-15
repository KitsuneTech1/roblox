local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create the ScreenGui
local adminGui = Instance.new("ScreenGui")
adminGui.Name = "AdminMenuGui"
adminGui.ResetOnSpawn = false
adminGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Create the Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(1, -110, 0, 10) -- Top right corner
toggleBtn.AnchorPoint = Vector2.new(1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.Text = "Toggle Admin"
toggleBtn.Parent = adminGui

local strokeToggle = Instance.new("UIStroke")
strokeToggle.Color = Color3.fromRGB(200, 200, 200)
strokeToggle.Thickness = 1
strokeToggle.Parent = toggleBtn
local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0, 4)
cornerToggle.Parent = toggleBtn

-- Create the Main Panel
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 200, 0, 250)
mainPanel.Position = UDim2.new(1, -110, 0, 50) -- Below toggle button
mainPanel.AnchorPoint = Vector2.new(1, 0)
mainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainPanel.Visible = false
mainPanel.Parent = adminGui

local strokePanel = Instance.new("UIStroke")
strokePanel.Color = Color3.fromRGB(150, 150, 150)
strokePanel.Thickness = 2
strokePanel.Parent = mainPanel
local cornerPanel = Instance.new("UICorner")
cornerPanel.CornerRadius = UDim.new(0, 8)
cornerPanel.Parent = mainPanel

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Text = "Admin Menu (Local)"
titleLabel.Parent = mainPanel

local coinDisplay = Instance.new("TextLabel")
coinDisplay.Name = "CoinDisplay"
coinDisplay.Size = UDim2.new(1, 0, 0, 20)
coinDisplay.BackgroundTransparency = 1
coinDisplay.TextColor3 = Color3.fromRGB(255, 215, 0)
coinDisplay.Font = Enum.Font.SourceSans
coinDisplay.TextSize = 16
coinDisplay.Text = "Coins: 0"
coinDisplay.Parent = mainPanel

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = mainPanel
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local uiPadding = Instance.new("UIPadding")
uiPadding.Parent = mainPanel
uiPadding.PaddingTop = UDim.new(0, 65)

-- Function to create menu buttons
local function createButton(name, text, index)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 180, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Text = text
	btn.LayoutOrder = index
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 100, 100)
	stroke.Thickness = 1
	stroke.Parent = btn
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = btn
	
	btn.Parent = mainPanel
	return btn
end

-- Create Action Buttons
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(0, 180, 0, 40)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.SourceSansBold
speedInput.TextSize = 18
speedInput.PlaceholderText = "Enter Speed (e.g. 100)"
speedInput.Text = ""
speedInput.LayoutOrder = 1
speedInput.ClearTextOnFocus = false

local strokeSpeed = Instance.new("UIStroke")
strokeSpeed.Color = Color3.fromRGB(100, 100, 100)
strokeSpeed.Thickness = 1
strokeSpeed.Parent = speedInput
local cornerSpeed = Instance.new("UICorner")
cornerSpeed.CornerRadius = UDim.new(0, 4)
cornerSpeed.Parent = speedInput
speedInput.Parent = mainPanel

local godModeBtn = createButton("GodModeButton", "God Mode (Inf HP)", 2)
local currencyBtn = createButton("CurrencyButton", "Add 1000 Coins", 3)

-- Toggle Menu Logic
toggleBtn.MouseButton1Click:Connect(function()
	mainPanel.Visible = not mainPanel.Visible
end)

-- Execute Admin Commands (Firing Server via Remote)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminRemote = ReplicatedStorage:WaitForChild("AdminRemote")

speedInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(speedInput.Text)
		if num then
			AdminRemote:FireServer("SetSpeed", num)
			print("Admin: Requested Speed " .. num)
		end
		speedInput.Text = ""
	end
end)

godModeBtn.MouseButton1Click:Connect(function()
	AdminRemote:FireServer("GodMode")
	print("Admin: Requested God Mode")
end)

currencyBtn.MouseButton1Click:Connect(function()
	AdminRemote:FireServer("AddCoins", 1000)
	print("Admin: Requested 1000 Coins")
end)

-- Coin Display Update
task.spawn(function()
    while task.wait(0.5) do
        local leaderstats = player:FindFirstChild("leaderstats")
        local coins = leaderstats and leaderstats:FindFirstChild("Coins")
        if coins then
            coinDisplay.Text = "Coins: " .. tostring(coins.Value)
        else
            coinDisplay.Text = "Coins: (Loading...)"
        end
    end
end)

-- Parent mapping happens last to draw the UI securely
adminGui.Parent = playerGui
