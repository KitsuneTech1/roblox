local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpgradeStatRemote = ReplicatedStorage:WaitForChild("UpgradeStatRequest")
local GetStatsRemote = ReplicatedStorage:WaitForChild("GetStatsRequest")

local screenGui = PlayerGui:WaitForChild("DiveHUD")

-- Create Upgrade Shop Panel
local upgradeFrame = Instance.new("Frame")
upgradeFrame.Size = UDim2.new(0, 400, 0, 500)
upgradeFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
upgradeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
upgradeFrame.BorderSizePixel = 0
upgradeFrame.Visible = false
upgradeFrame.Parent = screenGui

local upgradeCorner = Instance.new("UICorner")
upgradeCorner.CornerRadius = UDim.new(0, 16)
upgradeCorner.Parent = upgradeFrame

local upgradeStroke = Instance.new("UIStroke")
upgradeStroke.Color = Color3.fromRGB(0, 255, 150)
upgradeStroke.Thickness = 2
upgradeStroke.Parent = upgradeFrame

local title = Instance.new("TextLabel")
title.Text = "Stat Upgrades"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.Parent = upgradeFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = upgradeFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    upgradeFrame.Visible = false
end)

-- Create rows for each stat
local function createStatRow(statName, displayName, yPos)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.9, 0, 0, 80)
    row.Position = UDim2.new(0.05, 0, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    row.Parent = upgradeFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = displayName .. " (Lvl ?)"
    nameLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextSize = 18
    nameLabel.Parent = row
    
    local buyBtn = Instance.new("TextButton")
    buyBtn.Text = "Loading..."
    buyBtn.Size = UDim2.new(0.3, 0, 0.6, 0)
    buyBtn.Position = UDim2.new(0.65, 0, 0.2, 0)
    buyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 16
    buyBtn.Parent = row
    
    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 8)
    buyCorner.Parent = buyBtn
    
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Text = ""
    errorLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    errorLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    errorLabel.BackgroundTransparency = 1
    errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextXAlignment = Enum.TextXAlignment.Left
    errorLabel.TextSize = 14
    errorLabel.Parent = row

    return nameLabel, buyBtn, errorLabel
end

local speedName, speedBtn, speedErr = createStatRow("SwimSpeed", "Swim Speed", 80)
local luckName, luckBtn, luckErr = createStatRow("Luck", "Find Luck", 180)
local oxyName, oxyBtn, oxyErr = createStatRow("MaxOxygen", "Max Oxygen", 280)

local function refreshShopMenu()
    local result = GetStatsRemote:InvokeServer()
    if not result then return end
    
    speedName.Text = "Swim Speed (Lvl " .. result.SwimSpeedLevel .. ")"
    speedBtn.Text = result.SwimSpeedCost .. " Coins"
    
    luckName.Text = "Find Luck (Lvl " .. result.LuckLevel .. ")"
    luckBtn.Text = result.LuckCost .. " Coins"
    
    oxyName.Text = "Max Oxygen (Lvl " .. result.MaxOxygenLevel .. ")"
    oxyBtn.Text = result.MaxOxygenCost .. " Coins"
end

-- Wire up purchase buttons
local function wirePurchase(statName, btn, errLabel)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        local success, msg = UpgradeStatRemote:InvokeServer(statName)
        
        if success then
            errLabel.Text = "Upgraded!"
            errLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            refreshShopMenu()
        else
            errLabel.Text = msg
            errLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            refreshShopMenu()
        end
        
        task.wait(2)
        errLabel.Text = ""
    end)
end

wirePurchase("SwimSpeed", speedBtn, speedErr)
wirePurchase("Luck", luckBtn, luckErr)
wirePurchase("MaxOxygen", oxyBtn, oxyErr)

-- Hook up the event from the physical booth
local OpenUpgradeShopEvent = ReplicatedStorage:WaitForChild("OpenUpgradeShopEvent")
OpenUpgradeShopEvent.OnClientEvent:Connect(function()
    upgradeFrame.Visible = true
    refreshShopMenu()
end)
