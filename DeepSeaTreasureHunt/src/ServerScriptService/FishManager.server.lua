local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local FishManager = {}
FishManager.FishSchools = {}

local rng = Random.new()

-- Fish Configuration
local FISH_TYPES = {
    { Name = "Neon Tetra", Color = Color3.fromRGB(0, 255, 255), Size = 0.5, Speed = 10 },
    { Name = "Goldfish", Color = Color3.fromRGB(255, 165, 0), Size = 0.6, Speed = 8 },
    { Name = "Blue Tang", Color = Color3.fromRGB(0, 0, 255), Size = 0.7, Speed = 12 }
}

local SCHOOL_COUNT = 15
local FISH_PER_SCHOOL = 8
local SPAWN_BOUNDS = { minX = -500, maxX = 500, minY = -150, maxY = -10, minZ = -500, maxZ = 500 }

function FishManager.SpawnFish(type, schoolPos)
    local fish = Instance.new("Part")
    fish.Name = type.Name
    fish.Size = Vector3.new(type.Size, type.Size * 0.5, type.Size * 1.5)
    fish.Position = schoolPos + Vector3.new(rng:NextNumber(-10, 10), rng:NextNumber(-5, 5), rng:NextNumber(-10, 10))
    fish.Color = type.Color
    fish.Material = Enum.Material.Neon
    fish.Anchored = true
    fish.CanCollide = false
    fish.Parent = Workspace
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Parent = fish

    return {
        Part = fish,
        Type = type,
        Target = fish.Position,
        Offset = Vector3.new(rng:NextNumber(-5, 5), rng:NextNumber(-3, 3), rng:NextNumber(-5, 5))
    }
end

function FishManager.Initialize()
    for i = 1, SCHOOL_COUNT do
        local type = FISH_TYPES[rng:NextInteger(1, #FISH_TYPES)]
        local schoolCenter = Vector3.new(
            rng:NextNumber(SPAWN_BOUNDS.minX, SPAWN_BOUNDS.maxX),
            rng:NextNumber(SPAWN_BOUNDS.minY, SPAWN_BOUNDS.maxY),
            rng:NextNumber(SPAWN_BOUNDS.minZ, SPAWN_BOUNDS.maxZ)
        )
        
        local school = {
            Center = schoolCenter,
            Fish = {},
            Type = type,
            Velocity = Vector3.new(rng:NextNumber(-1, 1), 0, rng:NextNumber(-1, 1)).Unit * type.Speed
        }
        
        for j = 1, FISH_PER_SCHOOL do
            table.insert(school.Fish, FishManager.SpawnFish(type, schoolCenter))
        end
        
        table.insert(FishManager.FishSchools, school)
    end
    
    -- Movement Loop
    task.spawn(function()
        while true do
            local dt = task.wait(0.1)
            for _, school in ipairs(FishManager.FishSchools) do
                -- Update school center
                school.Center = school.Center + school.Velocity * dt
                
                -- Wander logic
                if rng:NextNumber() < 0.05 then
                    local newDir = (school.Velocity + Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.2, 0.2), rng:NextNumber(-1, 1))).Unit
                    school.Velocity = newDir * school.Type.Speed
                end
                
                -- Bounds check
                if school.Center.X < SPAWN_BOUNDS.minX or school.Center.X > SPAWN_BOUNDS.maxX or
                   school.Center.Z < SPAWN_BOUNDS.minZ or school.Center.Z > SPAWN_BOUNDS.maxZ or
                   school.Center.Y < SPAWN_BOUNDS.minY or school.Center.Y > SPAWN_BOUNDS.maxY then
                    school.Velocity = (Vector3.new(0, -50, 0) - school.Center).Unit * school.Type.Speed
                end
                
                -- Update each fish
                for _, fishData in ipairs(school.Fish) do
                    local targetPos = school.Center + fishData.Offset
                    fishData.Part.CFrame = CFrame.lookAt(fishData.Part.Position, targetPos) * CFrame.new(0, 0, -school.Type.Speed * dt)
                    fishData.Part.Position = fishData.Part.Position:Lerp(targetPos, 0.1)
                end
            end
        end
    end)
end

FishManager.Initialize()

return FishManager
