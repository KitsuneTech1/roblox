local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local WorldDecorator = {}
local rng = Random.new()

-- 1. Setup Professional Lighting
function WorldDecorator.SetupEnvironment()
    -- Atmosphere for underwater feel
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Density = 0.4
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(0, 100, 200)
    atmosphere.Decay = Color3.fromRGB(0, 0, 50)
    atmosphere.Glare = 0.2
    atmosphere.Haze = 2
    atmosphere.Parent = Lighting

    -- Bloom for glowing objects
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 1
    bloom.Size = 24
    bloom.Threshold = 0.8
    bloom.Parent = Lighting

    -- Color Correction
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Brightness = 0.05
    cc.Contrast = 0.1
    cc.Saturation = 0.2
    cc.TintColor = Color3.fromRGB(200, 230, 255)
    cc.Parent = Lighting

    -- Sun Rays
    local rays = Instance.new("SunRaysEffect")
    rays.Intensity = 0.1
    rays.Spread = 1
    rays.Parent = Lighting

    Lighting.FogColor = Color3.fromRGB(0, 10, 30)
    Lighting.FogEnd = 500
    Lighting.Ambient = Color3.fromRGB(40, 40, 60)
end

-- 2. Spawn Glowing Crystals
function WorldDecorator.SpawnCrystals(count)
    for i = 1, count do
        local crystal = Instance.new("Part")
        crystal.Name = "SeaCrystal"
        
        -- Random size and shape
        local size = rng:NextNumber(2, 6)
        crystal.Size = Vector3.new(size * 0.5, size * 1.5, size * 0.5)
        
        -- Place on "floor" (procedural logic simplified for this map)
        local x = rng:NextNumber(-950, 950)
        local z = rng:NextNumber(-950, 950)
        local y = -rng:NextNumber(50, 1500)
        
        crystal.Position = Vector3.new(x, y, z)
        crystal.Orientation = Vector3.new(rng:NextNumber(-20, 20), rng:NextNumber(0, 360), rng:NextNumber(-20, 20))
        
        crystal.Anchored = true
        crystal.CanCollide = false
        
        -- Neon glow
        local colors = {
            Color3.fromRGB(0, 255, 255), -- Azure
            Color3.fromRGB(255, 0, 255), -- Magenta
            Color3.fromRGB(0, 255, 0),   -- Lime
            Color3.fromRGB(255, 255, 255) -- White
        }
        local color = colors[rng:NextInteger(1, #colors)]
        crystal.Color = color
        crystal.Material = Enum.Material.Neon
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Brick
        mesh.Scale = Vector3.new(1, 1, 1)
        mesh.Parent = crystal
        
        local light = Instance.new("PointLight")
        light.Color = color
        light.Range = 20
        light.Brightness = 2
        light.Parent = crystal
        
        crystal.Parent = Workspace
    end
end

WorldDecorator.SetupEnvironment()
WorldDecorator.SpawnCrystals(500)

return WorldDecorator
