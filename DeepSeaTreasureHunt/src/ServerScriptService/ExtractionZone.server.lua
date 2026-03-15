local Workspace = game:GetService("Workspace")
local InventoryManager = require(script.Parent:WaitForChild("InventoryManager"))

-- Create the extraction zone part
local extractionZone = Instance.new("Part")
extractionZone.Name = "ExtractionZone"
extractionZone.Size = Vector3.new(20, 2, 20)
extractionZone.Position = Vector3.new(0, 7, 30) -- Moved up onto the Starter Island
extractionZone.Anchored = true
extractionZone.CanCollide = false
extractionZone.Color = Color3.fromRGB(0, 255, 100)
extractionZone.Material = Enum.Material.Neon
extractionZone.Transparency = 0.5
extractionZone.Parent = Workspace

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Sell Bag"
prompt.ObjectText = "Extraction Point"
prompt.HoldDuration = 1.5
prompt.RequiresLineOfSight = false
prompt.Parent = extractionZone

prompt.Triggered:Connect(function(player)
    local items = InventoryManager.ExtractArtifacts(player)
    
    if #items == 0 then
        print(player.Name .. " has nothing to sell.")
        return
    end

    local totalValue = 0
    for _, item in ipairs(items) do
        totalValue += item.Value
    end

    print(player.Name .. " sold " .. #items .. " artifacts for " .. totalValue .. " Coins!")
    player.leaderstats.Coins.Value += totalValue
end)
