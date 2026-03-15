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
    REEF_EDGE = { Speed = 25, Size = 1.0, Count = 10, Type = PREDATORS.SHARK, MinY = -350, MaxY = -150 },
    TWILIGHT = { Speed = 40, Size = 1.5, Count = 15, Type = PREDATORS.SHARK, MinY = -600, MaxY = -350 },
    ABYSSAL = { Speed = 60, Size = 2.5, Count = 20, Type = PREDATORS.SHARK, MinY = -850, MaxY = -600 },
    VOID = { Speed = 100, Size = 8.0, Count = 5, Type = PREDATORS.LEVIATHAN, MinY = -2000, MaxY = -850 }
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
    predator.Massless = true -- Make it easier to move
    
    -- Visuals: Shark-like shape
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1, 0.8, 2)
    mesh.Parent = predator

    -- Physical Constraints for Movement
    local attachment = Instance.new("Attachment")
    attachment.Parent = predator

    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.MaxForce = 999999
    linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVelocity.Attachment0 = attachment
    linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    linearVelocity.Parent = predator

    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.MaxTorque = 999999
    alignOrientation.Responsiveness = 20
    alignOrientation.Attachment0 = attachment
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.Parent = predator

    -- AI State Variables
    local patrolTarget = predator.Position

    -- Damage logic
    predator.Touched:Connect(function(hit)
        local character = hit.Parent
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(config.Type.Damage)
        end
    end)

    predator.Parent = Workspace
    
    -- AI Loop
    task.spawn(function()
        while predator and predator.Parent do
            local currentPos = predator.Position
            
            -- Find nearest player
            local targetPart = nil
            local nearestDist = config.Type.DetectionRange
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - currentPos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        targetPart = root
                    end
                end
            end

            local destination = patrolTarget
            if targetPart then
                -- CHASE
                destination = targetPart.Position
            else
                -- PATROL
                if (currentPos - patrolTarget).Magnitude < 30 then
                    patrolTarget = Vector3.new(
                        rng:NextNumber(-950, 950),
                        rng:NextNumber(config.MinY, config.MaxY),
                        rng:NextNumber(-950, 950)
                    )
                end
                destination = patrolTarget
            end
            
            -- Update Movement
            local direction = (destination - currentPos).Unit
            if destination == currentPos then direction = Vector3.new(0,0,0) end
            
            linearVelocity.VectorVelocity = direction * config.Speed
            alignOrientation.CFrame = CFrame.lookAt(currentPos, currentPos + direction)
            
            task.wait(0.1) -- Faster update for smoother AI
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
