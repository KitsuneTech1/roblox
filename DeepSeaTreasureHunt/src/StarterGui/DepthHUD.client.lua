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
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DepthHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0.05, 0, 0.6, 0)
    container.Position = UDim2.new(0.92, 0, 0.2, 0)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 2
    container.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = container

    -- Depth Bar Background
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.2, 0, 0.9, 0)
    bar.Position = UDim2.new(0.4, 0, 0.05, 0)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.Parent = container

    -- Layer Colors on Bar
    for i, layer in ipairs(LAYERS) do
        local layerIndicator = Instance.new("Frame")
        layerIndicator.Name = layer.Name
        
        -- Map depth to Y position (normalized 0 to 1)
        local totalRange = 1000 -- Max depth we track visually
        local top = math.abs(layer.MaxY) / totalRange
        local bottom = math.abs(layer.MinY) / totalRange
        
        layerIndicator.Size = UDim2.new(1, 0, bottom - top, 0)
        layerIndicator.Position = UDim2.new(0, 0, top, 0)
        layerIndicator.BackgroundColor3 = layer.Color
        layerIndicator.BorderSizePixel = 0
        layerIndicator.Parent = bar
    end

    -- Player Marker (Profile Picture)
    local marker = Instance.new("ImageLabel")
    marker.Name = "PlayerMarker"
    marker.Size = UDim2.new(2.5, 0, 0, 0) -- Aspect ratio set by script
    marker.Position = UDim2.new(-0.75, 0, 0, 0)
    marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    marker.BorderSizePixel = 2
    marker.ZIndex = 5
    marker.Parent = bar
    
    local markerCorner = Instance.new("UICorner")
    markerCorner.CornerRadius = UDim.new(1, 0)
    markerCorner.Parent = marker
    
    -- Set Profile Picture
    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    marker.Image = content

    -- Aspect ratio constraint for marker
    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 1
    aspect.Parent = marker

    -- Depth Text
    local depthLabel = Instance.new("TextLabel")
    depthLabel.Name = "DepthLabel"
    depthLabel.Size = UDim2.new(2, 0, 0.05, 0)
    depthLabel.Position = UDim2.new(-0.5, 0, 1.02, 0)
    depthLabel.BackgroundTransparency = 1
    depthLabel.Text = "0m"
    depthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    depthLabel.TextScaled = true
    depthLabel.Font = Enum.Font.GothamBold
    depthLabel.Parent = container

    -- Layer Name Text
    local layerLabel = Instance.new("TextLabel")
    layerLabel.Name = "LayerLabel"
    layerLabel.Size = UDim2.new(4, 0, 0.05, 0)
    layerLabel.Position = UDim2.new(-1.5, 0, -0.07, 0)
    layerLabel.BackgroundTransparency = 1
    layerLabel.Text = "Surface"
    layerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    layerLabel.TextScaled = true
    layerLabel.Font = Enum.Font.GothamBold
    layerLabel.Parent = container

    -- Update Loop
    RunService.RenderStepped:Connect(function()
        local character = player.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local depth = math.floor(rootPart.Position.Y)
        depthLabel.Text = tostring(math.abs(depth)) .. "m"

        -- Update Marker Position
        local totalRange = 1000
        local normalizedDepth = math.clamp(math.abs(depth) / totalRange, 0, 1)
        marker.Position = UDim2.new(-0.75, 0, normalizedDepth, -marker.AbsoluteSize.Y/2)

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
