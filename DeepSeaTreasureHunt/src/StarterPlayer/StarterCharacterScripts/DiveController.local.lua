local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local Lighting = game:GetService("Lighting")

-- Configure base lighting
Lighting.FogColor = Color3.fromRGB(10, 20, 50)
Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)

local function updateLighting()
    local depth = math.clamp(-rootPart.Position.Y, 0, 500)
    
    if rootPart.Position.Y < 0 then
        -- Underwater properties
        Lighting.Ambient = Color3.fromRGB(
            math.max(0, 50 - depth * 0.1),
            math.max(0, 100 - depth * 0.2),
            math.max(50, 150 - depth * 0.3)
        )
        Lighting.FogEnd = math.max(30, 250 - depth * 0.4)
    else
        -- Above water
        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
        Lighting.FogEnd = 100000
    end
end

local diveVelocity = Instance.new("LinearVelocity")
diveVelocity.Name = "DiveVelocity"
diveVelocity.MaxForce = 10000
diveVelocity.VectorVelocity = Vector3.new(0, 0, 0)
diveVelocity.RelativeTo = Enum.ActuatorRelativeTo.World

local attachment = Instance.new("Attachment")
attachment.Name = "DiveAttachment"
attachment.Parent = rootPart
diveVelocity.Attachment0 = attachment
diveVelocity.Parent = rootPart
diveVelocity.Enabled = false

local isDiving = false
local BASE_SWIM_SPEED = 15
local BASE_DIVE_SPEED = 10

-- Input Handling for 3D Movement
local function handleSwimming(deltaTime)
    -- In a real game, this would sync from a RemoteFunction on spawn, but for 
    -- rapid prototyping we can just pull a Value object if it exists or default it.
    local speedMultiplier = 1
    local speedLevelValue = player:FindFirstChild("SwimSpeedLevel")
    if speedLevelValue then
        speedMultiplier = 1 + (speedLevelValue.Value - 1) * 0.2 -- +20% speed per level
    end

    local SWIM_SPEED = BASE_SWIM_SPEED * speedMultiplier
    local DIVE_SPEED = BASE_DIVE_SPEED * speedMultiplier

    local depth = rootPart.Position.Y
    local isUnderwater = depth < 0
    
    -- Toggle diving state based on depth
    if isUnderwater and not isDiving then
        isDiving = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        diveVelocity.Enabled = true
        workspace.Gravity = 0 -- Neutral buoyancy
    elseif not isUnderwater and isDiving then
        isDiving = false
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        diveVelocity.Enabled = false
        workspace.Gravity = 196.2
    end
    
    -- Apply movement if underwater
    if isDiving then
        local moveVector = require(Players.LocalPlayer.PlayerScripts.PlayerModule):GetControls():GetMoveVector()
        local cameraCFrame = workspace.CurrentCamera.CFrame
        
        -- Translate 2D input into 3D camera-relative world space
        local moveDirection = (cameraCFrame.RightVector * moveVector.X + cameraCFrame.LookVector * -moveVector.Z)
        
        -- Default vertical movement (Space to go up, Ctrl/Shift to go down)
        local verticalVelocity = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            verticalVelocity = DIVE_SPEED
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            verticalVelocity = -DIVE_SPEED
        end
        
        -- Combine horizontal and vertical
        local finalVelocity = (moveDirection * SWIM_SPEED) + Vector3.new(0, verticalVelocity, 0)
        
        -- Smoothly interpolate current velocity to target velocity
        diveVelocity.VectorVelocity = diveVelocity.VectorVelocity:Lerp(finalVelocity, deltaTime * 10)
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    if rootPart and humanoid.Health > 0 then
        updateLighting()
        handleSwimming(deltaTime)
    end
end)
