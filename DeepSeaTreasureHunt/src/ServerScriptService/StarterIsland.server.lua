local Workspace = game:GetService("Workspace")

-- Create the Island Platform
local island = Instance.new("Part")
island.Name = "StarterIsland"
island.Size = Vector3.new(100, 5, 100)
island.Position = Vector3.new(0, 2.5, 0) -- Just above the surface
island.Anchored = true
island.Color = Color3.fromRGB(194, 178, 128) -- Sand color
island.Material = Enum.Material.Sand
island.Parent = Workspace

-- Create a SpawnLocation on the island
local spawnPoint = Instance.new("SpawnLocation")
spawnPoint.Name = "StarterSpawn"
spawnPoint.Size = Vector3.new(10, 1, 10)
spawnPoint.Position = Vector3.new(0, 5.5, 0)
spawnPoint.Anchored = true
spawnPoint.Color = Color3.fromRGB(0, 255, 0)
spawnPoint.TeamColor = BrickColor.new("Bright green")
spawnPoint.AllowTeamChangeOnTouch = false
spawnPoint.Duration = 0
spawnPoint.Parent = Workspace

-- Create a Physical Shop Booth
local shopBooth = Instance.new("Part")
shopBooth.Name = "GachaShopBooth"
shopBooth.Size = Vector3.new(20, 10, 10)
shopBooth.Position = Vector3.new(0, 10, -30)
shopBooth.Anchored = true
shopBooth.Color = Color3.fromRGB(150, 100, 50) -- Wood color
shopBooth.Material = Enum.Material.Wood
shopBooth.Parent = Workspace

local shopSign = Instance.new("Part")
shopSign.Name = "ShopSign"
shopSign.Size = Vector3.new(20, 5, 2)
shopSign.Position = Vector3.new(0, 15, -30)
shopSign.Anchored = true
shopSign.Color = Color3.fromRGB(50, 50, 50)
shopSign.Parent = Workspace

local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Face = Enum.NormalId.Front
surfaceGui.Parent = shopSign

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Submersible Gear Shop"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBlack
textLabel.Parent = surfaceGui

-- Shop Proximity Prompt (To open the Gacha menu)
local shopPrompt = Instance.new("ProximityPrompt")
shopPrompt.ActionText = "Open Shop"
shopPrompt.ObjectText = "Gear Details"
shopPrompt.HoldDuration = 0
shopPrompt.Parent = shopBooth

-- To open the local UI from a server script, we can fire a RemoteEvent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OpenShopEvent = Instance.new("RemoteEvent")
OpenShopEvent.Name = "OpenShopEvent"
OpenShopEvent.Parent = ReplicatedStorage

shopPrompt.Triggered:Connect(function(player)
    OpenShopEvent:FireClient(player)
end)

-- Create a Physical Upgrade Booth
local upgradeBooth = Instance.new("Part")
upgradeBooth.Name = "UpgradeShopBooth"
upgradeBooth.Size = Vector3.new(20, 10, 10)
upgradeBooth.Position = Vector3.new(30, 10, -30) -- Placed next to the other shop
upgradeBooth.Anchored = true
upgradeBooth.Color = Color3.fromRGB(100, 150, 150) -- Slate color
upgradeBooth.Material = Enum.Material.Slate
upgradeBooth.Parent = Workspace

local upgradeSign = Instance.new("Part")
upgradeSign.Name = "UpgradeSign"
upgradeSign.Size = Vector3.new(20, 5, 2)
upgradeSign.Position = Vector3.new(30, 15, -30)
upgradeSign.Anchored = true
upgradeSign.Color = Color3.fromRGB(50, 50, 50)
upgradeSign.Parent = Workspace

local upgradeGui = Instance.new("SurfaceGui")
upgradeGui.Face = Enum.NormalId.Front
upgradeGui.Parent = upgradeSign

local upgradeLabel = Instance.new("TextLabel")
upgradeLabel.Size = UDim2.new(1, 0, 1, 0)
upgradeLabel.BackgroundTransparency = 1
upgradeLabel.Text = "Stat Upgrades"
upgradeLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
upgradeLabel.TextScaled = true
upgradeLabel.Font = Enum.Font.GothamBlack
upgradeLabel.Parent = upgradeGui

local upgradePrompt = Instance.new("ProximityPrompt")
upgradePrompt.ActionText = "Open Shop"
upgradePrompt.ObjectText = "Upgrades"
upgradePrompt.HoldDuration = 0
upgradePrompt.Parent = upgradeBooth

local OpenUpgradeShopEvent = Instance.new("RemoteEvent")
OpenUpgradeShopEvent.Name = "OpenUpgradeShopEvent"
OpenUpgradeShopEvent.Parent = ReplicatedStorage

upgradePrompt.Triggered:Connect(function(player)
    OpenUpgradeShopEvent:FireClient(player)
end)
