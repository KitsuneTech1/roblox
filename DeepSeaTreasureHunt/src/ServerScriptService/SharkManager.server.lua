local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SharkManager = {}
SharkManager.Sharks = {}

local rng = Random.new()

-- Predator Types
local PREDATORS = {
    SHARK = {
        Name = "Shark",
        Color = Color3.fromRGB(100, 100, 120),
        Damage = 25,
        DetectionRange = 100,
    },
    LEVIATHAN = {
        Name = "Leviathan",
        Color = Color3.fromRGB(50, 0, 50),
        Damage = 100,
        DetectionRange = 300,
    }
}

-- Layer Difficulty Settings
local DIFFICULTY = {
    REEF_EDGE = { Speed = 15, Size = 1.0, Count = 10, Type = PREDATORS.SHARK, MinY = -350, MaxY = -150 },
    TWILIGHT = { Speed = 25, Size = 1.5, Count = 15, Type = PREDATORS.SHARK, MinY = -600, MaxY = -350 },
    ABYSSAL = { Speed = 40, Size = 2.5, Count = 20, Type = PREDATORS.SHARK, MinY = -850, MaxY = -600 },
    VOID = { Speed = 60, Size = 8.0, Count = 5, Type = PREDATORS.LEVIATHAN, MinY = -2000, MaxY = -850 }
}

function SharkManager.SpawnPredator(config)
    local predator = Instance.new("Part")
    predator.Name = config.Type.Name
    predator.Size = Vector3.new(4 * config.Size, 2 * config.Size, 10 * config.Size)
    
    -- Random spawn within layer bounds
    local x = rng:NextNumber(-950, 950)
    local y = rng:NextNumber(config.MinY, config.MaxY)
    local z = rng:NextNumber(-950, 950)
    predator.Position = Vector3.new(x, y, z)
    
    predator.Color = config.Type.Color
    predator.Material = Enum.Material.SmoothPlastic
    predator.CanCollide = false
    predator.Anchored = false
    
    -- Visuals: Shark-like shape
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1, 0.8, 2)
    mesh.Parent = predator

    local attachment = Instance.new("Attachment")
    attachment.Parent = predator

    local alignPosition = Instance.new("AlignPosition")
    alignPosition.Attachment0 = attachment
    alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPosition.MaxForce = 100000 * config.Size
    alignPosition.Responsiveness = 10
    alignPosition.Parent = predator

    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Attachment0 = attachment
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.MaxTorque = 100000 * config.Size
    alignOrientation.Responsiveness = 10
    alignOrientation.Parent = predator

    -- AI State Variables
    local targetPlayer = nil
    local patrolTarget = predator.Position

    -- Damage logic
    predator.Touched:Connect(function(hit)
        local character = hit.Parent
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(config.Type.Damage)
            -- Knockback or simple cooldown could be added here
        end
    end)

    predator.Parent = Workspace
    
    -- AI Loop
    task.spawn(function()
        while predator and predator.Parent do
            local currentPos = predator.Position
            
            -- Find nearest player
            targetPlayer = nil
            local nearestDist = config.Type.DetectionRange
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local dist = (char.HumanoidRootPart.Position - currentPos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        targetPlayer = char.HumanoidRootPart
                    end
                end
            end

            if targetPlayer then
                -- CHASE
                alignPosition.Position = targetPlayer.Position
                alignOrientation.CFrame = CFrame.lookAt(currentPos, targetPlayer.Position)
            else
                -- PATROL
                if (currentPos - patrolTarget).Magnitude < 20 then
                    patrolTarget = Vector3.new(
                        rng:NextNumber(-950, 950),
                        rng:NextNumber(config.MinY, config.MaxY),
                        rng:NextNumber(-950, 950)
                    )
                end
                alignPosition.Position = patrolTarget
                alignOrientation.CFrame = CFrame.lookAt(currentPos, patrolTarget)
            end
            
            -- Dynamic speed
            alignPosition.MaxVelocity = config.Speed
            
            task.wait(0.5)
        end
    end)

    table.insert(SharkManager.Sharks, predator)
end

-- Initialize Predators for each layer
for layerKey, config in pairs(DIFFICULTY) do
    for i = 1, config.Count do
        SharkManager.SpawnPredator(config)
    end
end

return SharkManager
