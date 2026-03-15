local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local ArtifactManager = {}
ArtifactManager.Artifacts = {}

local rng = Random.new()

-- Initialize leaderstats for new players
Players.PlayerAdded:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    if not leaderstats:FindFirstChild("Coins") then
        local coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Value = 0
        coins.Parent = leaderstats
    end
end)

-- Define Depth Layers
local LAYERS = {
    SHALLOW = { MinY = -150, MaxY = 0, Name = "Shallow Waters" },
    REEF_EDGE = { MinY = -350, MaxY = -150, Name = "Reef Edge" },
    TWILIGHT = { MinY = -600, MaxY = -350, Name = "Twilight Reach" },
    ABYSSAL = { MinY = -850, MaxY = -600, Name = "Abyssal Floor" },
    VOID = { MinY = -2000, MaxY = -850, Name = "The Void" }
}

-- Define Artifact Pool with Rarities and properties
local ArtifactPool = {
    SHALLOW = {
        { Name = "Scrap Metal", Value = 10, Rarity = "Common", Color = Color3.fromRGB(130, 130, 130), Size = Vector3.new(1.5, 1.5, 1.5) },
        { Name = "Old Boot", Value = 15, Rarity = "Common", Color = Color3.fromRGB(101, 67, 33), Size = Vector3.new(2, 1, 1) },
    },
    REEF_EDGE = {
        { Name = "Silver Coin", Value = 50, Rarity = "Uncommon", Color = Color3.fromRGB(192, 192, 192), Size = Vector3.new(1, 1, 1) },
        { Name = "Pearl", Value = 250, Rarity = "Epic", Color = Color3.fromRGB(255, 240, 245), Size = Vector3.new(1.5, 1.5, 1.5) },
    },
    TWILIGHT = {
        { Name = "Gold Coin", Value = 100, Rarity = "Rare", Color = Color3.fromRGB(255, 215, 0), Size = Vector3.new(1, 1, 1) },
        { Name = "Sunken Chest", Value = 800, Rarity = "Legendary", Color = Color3.fromRGB(139, 69, 19), Size = Vector3.new(3, 2, 2) },
    },
    ABYSSAL = {
        { Name = "Poseidon's Trident", Value = 2500, Rarity = "Mythic", Color = Color3.fromRGB(0, 255, 255), Size = Vector3.new(1, 4, 1) },
        { Name = "Ancient Relic", Value = 5000, Rarity = "Mythic", Color = Color3.fromRGB(255, 0, 255), Size = Vector3.new(4, 4, 4) },
    },
    VOID = {
        { Name = "Void Essence", Value = 15000, Rarity = "God Tier", Color = Color3.fromRGB(0, 0, 0), Size = Vector3.new(5, 5, 5) },
        { Name = "Eldritch Eye", Value = 50000, Rarity = "God Tier", Color = Color3.fromRGB(255, 255, 255), Size = Vector3.new(6, 6, 6) },
    }
}

function ArtifactManager.GetLayerForDepth(y)
    if y >= LAYERS.SHALLOW.MinY then return "SHALLOW"
    elseif y >= LAYERS.REEF_EDGE.MinY then return "REEF_EDGE"
    elseif y >= LAYERS.TWILIGHT.MinY then return "TWILIGHT"
    elseif y >= LAYERS.ABYSSAL.MinY then return "ABYSSAL"
    else return "VOID"
    end
end

function ArtifactManager.SpawnArtifact(position)
    local layerKey = ArtifactManager.GetLayerForDepth(position.Y)
    local pool = ArtifactPool[layerKey]
    local artifactType = pool[rng:NextInteger(1, #pool)]

    local artifact = Instance.new("Part")
    artifact.Name = "Artifact"
    artifact.Size = artifactType.Size
    artifact.Position = position
    artifact.Anchored = true
    artifact.CanCollide = false
    artifact.Color = artifactType.Color
    artifact.Material = Enum.Material.Neon
    artifact.Shape = Enum.PartType.Block
    
    if artifactType.Name:find("Coin") or artifactType.Name == "Pearl" or artifactType.Name:find("Eye") or artifactType.Name:find("Essence") then
        artifact.Shape = Enum.PartType.Ball
    end
    
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Salvage"
    prompt.ObjectText = artifactType.Name .. " (" .. artifactType.Rarity .. ")"
    prompt.HoldDuration = 1
    prompt.Parent = artifact
    
    local light = Instance.new("PointLight")
    light.Color = artifactType.Color
    light.Range = 25
    light.Brightness = 3
    light.Parent = artifact

    local InventoryManager = require(script.Parent:WaitForChild("InventoryManager"))

    prompt.Triggered:Connect(function(player)
        local valueMultiplier = 1
        local luckLevelValue = player:FindFirstChild("LuckLevel")
        if luckLevelValue then
            valueMultiplier = 1 + (luckLevelValue.Value - 1) * 0.5
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

-- Clear old artifacts if any (for hot reloading if supported)
for _, part in ipairs(Workspace:GetChildren()) do
    if part.Name == "Artifact" then part:Destroy() end
end

-- Spawn initial batch of artifacts - INCREASED DENSITY
ArtifactManager.SpawnBatch(2500, {
    minX = -950, maxX = 950,
    minY = -1500, maxY = -50,
    minZ = -950, maxZ = 950
})

return ArtifactManager
