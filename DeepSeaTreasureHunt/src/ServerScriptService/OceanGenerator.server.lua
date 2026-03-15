local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain

-- Ocean dimensions
local OCEAN_SIZE = Vector3.new(2000, 900, 2000)
local OCEAN_CENTER = CFrame.new(0, -450, 0)

-- Generate Ocean Water
Terrain:FillBlock(OCEAN_CENTER, OCEAN_SIZE, Enum.Material.Water)

print("Ocean generated at " .. tostring(OCEAN_SIZE))
