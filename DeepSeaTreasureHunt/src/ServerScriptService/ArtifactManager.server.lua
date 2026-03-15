local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local ArtifactManager = {}
ArtifactManager.Artifacts = {}

local rng = Random.new()

-- Initialize leaderstats for new players
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats
end)

-- Define Artifact Pool with Rarities and properties
local ArtifactPool = {
    { Name = "Scrap Metal", Value = 10, Rarity = "Common", Color = Color3.fromRGB(130, 130, 130), Size = Vector3.new(1.5, 1.5, 1.5) },
    { Name = "Old Boot", Value = 15, Rarity = "Common", Color = Color3.fromRGB(101, 67, 33), Size = Vector3.new(2, 1, 1) },
    { Name = "Silver Coin", Value = 50, Rarity = "Uncommon", Color = Color3.fromRGB(192, 192, 192), Size = Vector3.new(1, 1, 1) },
    { Name = "Gold Coin", Value = 100, Rarity = "Rare", Color = Color3.fromRGB(255, 215, 0), Size = Vector3.new(1, 1, 1) },
    { Name = "Pearl", Value = 250, Rarity = "Epic", Color = Color3.fromRGB(255, 240, 245), Size = Vector3.new(1.5, 1.5, 1.5) },
    { Name = "Sunken Chest", Value = 800, Rarity = "Legendary", Color = Color3.fromRGB(139, 69, 19), Size = Vector3.new(3, 2, 2) },
    { Name = "Poseidon's Trident", Value = 2500, Rarity = "Mythic", Color = Color3.fromRGB(0, 255, 255), Size = Vector3.new(1, 4, 1) },
}

-- Calculate total weight for weighted probability (optional, currently using uniform random for simplicity or custom weights)
-- For a quick variety update, we'll just pick randomly or use a simple depth-based check if wanted. Here we use basic random.

function ArtifactManager.SpawnArtifact(position)
    -- Randomly select an artifact type
    local index = rng:NextInteger(1, #ArtifactPool)
    local artifactType = ArtifactPool[index]

    local artifact = Instance.new("Part")
    artifact.Name = "Artifact"
    artifact.Size = artifactType.Size
    artifact.Position = position
    artifact.Anchored = true
    artifact.CanCollide = false
    artifact.Color = artifactType.Color
    artifact.Material = Enum.Material.Neon
    artifact.Shape = Enum.PartType.Block -- Default to block, but balls look better for small items.
    
    if artifactType.Name:find("Coin") or artifactType.Name == "Pearl" then
        artifact.Shape = Enum.PartType.Ball
    end
    
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Salvage"
    prompt.ObjectText = artifactType.Name
    prompt.HoldDuration = 1
    prompt.Parent = artifact
    
    local light = Instance.new("PointLight")
    light.Color = artifactType.Color
    light.Range = 25
    light.Brightness = 3
    light.Parent = artifact

    -- Use InventoryManager when salvaged
    local InventoryManager = require(script.Parent:WaitForChild("InventoryManager"))

    prompt.Triggered:Connect(function(player)
        local valueMultiplier = 1
        local luckLevelValue = player:FindFirstChild("LuckLevel")
        if luckLevelValue then
            valueMultiplier = 1 + (luckLevelValue.Value - 1) * 0.5 -- +50% artifact value per Luck level
        end
        
        local finalValue = math.floor(artifactType.Value * valueMultiplier)

        local success = InventoryManager.AddItem(player, InventoryManager.ItemTypes.Artifact, {
            Name = artifactType.Name,
            Value = finalValue,
            Rarity = artifactType.Rarity
        })
        
        if success then
            artifact:Destroy()
        end
    end)

    artifact.Parent = Workspace
    table.insert(ArtifactManager.Artifacts, artifact)
end

function ArtifactManager.SpawnBatch(count, bounds)
    for i = 1, count do
        local x = rng:NextNumber(bounds.minX, bounds.maxX)
        local y = rng:NextNumber(bounds.minY, bounds.maxY)
        local z = rng:NextNumber(bounds.minZ, bounds.maxZ)
        ArtifactManager.SpawnArtifact(Vector3.new(x, y, z))
    end
end

-- Spawn initial batch of artifacts
ArtifactManager.SpawnBatch(1000, {
    minX = -950, maxX = 950,
    minY = -850, maxY = -50,
    minZ = -950, maxZ = 950
})

return ArtifactManager
