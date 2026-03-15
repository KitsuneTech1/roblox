local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Create the UI Group
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DiveHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- 1. Depth Label Container
local depthFrame = Instance.new("Frame")
depthFrame.Size = UDim2.new(0, 220, 0, 60)
depthFrame.Position = UDim2.new(0.5, -110, 0, 20)
depthFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
depthFrame.BackgroundTransparency = 0.2
depthFrame.Parent = screenGui

local depthCorner = Instance.new("UICorner")
depthCorner.CornerRadius = UDim.new(0, 12)
depthCorner.Parent = depthFrame

local depthStroke = Instance.new("UIStroke")
depthStroke.Color = Color3.fromRGB(0, 200, 255)
depthStroke.Thickness = 2
depthStroke.Parent = depthFrame

local depthLabel = Instance.new("TextLabel")
depthLabel.Size = UDim2.new(1, 0, 1, 0)
depthLabel.BackgroundTransparency = 1
depthLabel.TextColor3 = Color3.fromRGB(220, 255, 255)
depthLabel.Font = Enum.Font.GothamBlack
depthLabel.TextScaled = true
depthLabel.Text = "Depth: 0m"
depthLabel.Parent = depthFrame

-- 2. Oxygen Bar Background
local oxygenBkg = Instance.new("Frame")
oxygenBkg.Size = UDim2.new(0, 350, 0, 35)
oxygenBkg.Position = UDim2.new(0.5, -175, 0, 90)
oxygenBkg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
oxygenBkg.Parent = screenGui

local oxyCorner = Instance.new("UICorner")
oxyCorner.CornerRadius = UDim.new(0, 18)
oxyCorner.Parent = oxygenBkg

local oxyStroke = Instance.new("UIStroke")
oxyStroke.Color = Color3.fromRGB(50, 50, 70)
oxyStroke.Thickness = 2
oxyStroke.Parent = oxygenBkg

-- 3. Oxygen Bar Fill (The blue part)
local oxygenFill = Instance.new("Frame")
oxygenFill.Size = UDim2.new(1, 0, 1, 0)
oxygenFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Base white to let Gradient shine
oxygenFill.BorderSizePixel = 0
oxygenFill.Parent = oxygenBkg

local oxyFillCorner = Instance.new("UICorner")
oxyFillCorner.CornerRadius = UDim.new(0, 18)
oxyFillCorner.Parent = oxygenFill

local oxyGradient = Instance.new("UIGradient")
oxyGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 200))
}
oxyGradient.Parent = oxygenFill

local oxygenText = Instance.new("TextLabel")
oxygenText.Size = UDim2.new(1, 0, 1, 0)
oxygenText.BackgroundTransparency = 1
oxygenText.TextColor3 = Color3.fromRGB(255, 255, 255)
oxygenText.TextStrokeTransparency = 0.5
oxygenText.Font = Enum.Font.GothamBold
oxygenText.TextSize = 20
oxygenText.Text = "Oxygen: 100s"
oxygenText.Parent = oxygenBkg

-- UI Update Loop
RunService.RenderStepped:Connect(function()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        -- Update Depth
        if rootPart then
            local depth = math.floor(math.max(0, -rootPart.Position.Y))
            depthLabel.Text = "Depth: " .. depth .. "m"
        end

        -- Update Oxygen Bar
        local oxygen = character:FindFirstChild("Oxygen")
        local maxOxygen = character:FindFirstChild("MaxOxygen")
        if oxygen and maxOxygen then
            local ratio = math.clamp(oxygen.Value / maxOxygen.Value, 0, 1)
            
            -- Smoothly scale the blue bar
            oxygenFill.Size = UDim2.new(ratio, 0, 1, 0)
            oxygenText.Text = "Oxygen: " .. math.floor(oxygen.Value) .. "s"
            
            -- Turn the bar red if they are drowning
            if oxygen.Value <= 0 then
                oxyGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
                }
                oxygenFill.Size = UDim2.new(1, 0, 1, 0)
                oxygenText.Text = "DROWNING!"
            else
                oxyGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 200))
                }
            end
        end
    end
end)
