local Players = game:GetService("Players")

local InventoryManager = {}
InventoryManager.Inventories = {} -- Dictionary mapping UserId to table of items

-- Define item types
InventoryManager.ItemTypes = {
    Artifact = "Artifact",
    Gear = "Gear"
}

-- Initialize empty inventory for new players
Players.PlayerAdded:Connect(function(player)
    InventoryManager.Inventories[player.UserId] = {
        Artifacts = {},
        Gear = {}
    }
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    InventoryManager.Inventories[player.UserId] = nil
end)

-- Add an item to a player's inventory
function InventoryManager.AddItem(player, itemType, itemData)
    local inv = InventoryManager.Inventories[player.UserId]
    if not inv then return false end
    
    if itemType == InventoryManager.ItemTypes.Artifact then
        table.insert(inv.Artifacts, itemData)
        print("Added artifact to " .. player.Name .. "'s inventory")
        return true
    elseif itemType == InventoryManager.ItemTypes.Gear then
        table.insert(inv.Gear, itemData)
        return true
    end
    
    return false
end

-- Get all artifacts for selling
function InventoryManager.ExtractArtifacts(player)
    local inv = InventoryManager.Inventories[player.UserId]
    if not inv then return {} end
    
    local extracted = inv.Artifacts
    inv.Artifacts = {} -- Empty their bag
    
    return extracted
end

function InventoryManager.GetInventory(player)
    return InventoryManager.Inventories[player.UserId]
end

return InventoryManager
