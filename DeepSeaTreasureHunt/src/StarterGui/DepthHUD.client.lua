local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Define Depth Layers (Synced with server)
local LAYERS = {
    { MinY = -150, MaxY = 0, Name = "Shallow Waters", Color = Color3.fromRGB(0, 170, 255) },
    { MinY = -350, MaxY = -150, Name = "Reef Edge", Color = Color3.fromRGB(0, 85, 255) },
    { MinY = -600, MaxY = -350, Name = "Twilight Reach", Color = Color3.fromRGB(0, 0, 127) },
    { MinY = -850, MaxY = -600, Name = "Abyssal Floor", Color = Color3.fromRGB(0, 0, 50) },
    { MinY = -2000, MaxY = -850, Name = "The Void", Color = Color3.fromRGB(20, 0, 20) }
}

local function createHUD()
    -- Ensure old HUD is removed
    local existing = playerGui:FindFirstChild("DepthHUD")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DepthHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0.08, 0, 0.6, 0)
    container.Position = UDim2.new(0.9, 0, 0.2, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    -- Depth Bar Background
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.15, 0, 0.9, 0)
    bar.Position = UDim2.new(0.7, 0, 0.05, 0)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.BorderSizePixel = 0
    bar.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = bar

    -- Layer Colors on Bar
    for i, layer in ipairs(LAYERS) do
        local layerIndicator = Instance.new("Frame")
        layerIndicator.Name = layer.Name
        
        local totalRange = 1000 -- Display range
        local top = math.abs(layer.MaxY) / totalRange
        local bottom = math.abs(layer.MinY) / totalRange
        
        layerIndicator.Size = UDim2.new(1, 0, math.clamp(bottom - top, 0, 1), 0)
        layerIndicator.Position = UDim2.new(0, 0, math.clamp(top, 0, 1), 0)
        layerIndicator.BackgroundColor3 = layer.Color
        layerIndicator.BorderSizePixel = 0
        layerIndicator.Parent = bar
    end

    -- Marker Container (moves with player)
    local markerFrame = Instance.new("Frame")
    markerFrame.Name = "MarkerFrame"
    markerFrame.Size = UDim2.new(1, 0, 0, 0)
    markerFrame.Position = UDim2.new(0, 0, 0, 0)
    markerFrame.BackgroundTransparency = 1
    markerFrame.Parent = bar

    -- The Line next to profile pic
    local line = Instance.new("Frame")
    line.Name = "IndicatorLine"
    line.Size = UDim2.new(1.5, 0, 0, 2)
    line.Position = UDim2.new(-1.5, 0, 0, -1)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.Parent = markerFrame

    -- Player Marker (Profile Picture)
    local marker = Instance.new("ImageLabel")
    marker.Name = "PlayerMarker"
    marker.Size = UDim2.new(3, 0, 3, 0) -- Bigger for visibility
    marker.Position = UDim2.new(-4.8, 0, 0, 0)
    marker.AnchorPoint = Vector2.new(0, 0.5)
    marker.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    marker.BorderSizePixel = 2
    marker.BorderColor3 = Color3.fromRGB(255, 255, 255)
    marker.ZIndex = 5
    marker.Parent = markerFrame
    
    local markerCorner = Instance.new("UICorner")
    markerCorner.CornerRadius = UDim.new(1, 0)
    markerCorner.Parent = marker
    
    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 1
    aspect.Parent = marker
    
    -- Load Profile Picture
    task.spawn(function()
        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if success then
            marker.Image = content
        end
    end)

    -- Depth Text
    local depthLabel = Instance.new("TextLabel")
    depthLabel.Name = "DepthLabel"
    depthLabel.Size = UDim2.new(3, 0, 0.05, 0)
    depthLabel.Position = UDim2.new(-2, 0, 1.02, 0)
    depthLabel.BackgroundTransparency = 1
    depthLabel.Text = "0m"
    depthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    depthLabel.TextScaled = true
    depthLabel.Font = Enum.Font.GothamBold
    depthLabel.Parent = container

    -- Layer Name Text
    local layerLabel = Instance.new("TextLabel")
    layerLabel.Name = "LayerLabel"
    layerLabel.Size = UDim2.new(5, 0, 0.05, 0)
    layerLabel.Position = UDim2.new(-3, 0, -0.07, 0)
    layerLabel.BackgroundTransparency = 1
    layerLabel.Text = "Surface"
    layerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    layerLabel.TextScaled = true
    layerLabel.Font = Enum.Font.GothamBold
    layerLabel.Parent = container

    -- Update Loop
    RunService.RenderStepped:Connect(function()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local depth = rootPart.Position.Y
        local absDepth = math.abs(math.floor(depth))
        depthLabel.Text = tostring(absDepth) .. "m"

        -- Update Marker Position
        local totalRange = 1000
        local normalizedDepth = math.clamp(math.abs(depth) / totalRange, 0, 1)
        markerFrame.Position = UDim2.new(0, 0, normalizedDepth, 0)

        -- Update Layer Label
        local currentLayer = "Deep Water"
        local currentColor = Color3.fromRGB(255, 255, 255)
        for _, layer in ipairs(LAYERS) do
            if depth >= layer.MinY and depth <= layer.MaxY then
                currentLayer = layer.Name
                currentColor = layer.Color
                break
            end
        end
        layerLabel.Text = currentLayer
        layerLabel.TextColor3 = currentColor
    end)
end

createHUD()
