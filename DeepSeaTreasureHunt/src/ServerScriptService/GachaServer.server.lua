local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryManager = require(script.Parent:WaitForChild("InventoryManager"))

-- Create RemoteFunction for Gacha Rolls
local GachaRollRemote = Instance.new("RemoteFunction")
GachaRollRemote.Name = "GachaRollRequest"
GachaRollRemote.Parent = ReplicatedStorage

local ROLL_COST = 500

-- Define Gear Pool with Rarities (Weights)
local GearPool = {
    { Name = "Rusty Tank", Type = "Tank", Rarity = "Common", Weight = 60, Bonus = { MaxOxygen = 120 } },
    { Name = "Standard Flippers", Type = "Flippers", Rarity = "Common", Weight = 60, Bonus = { SwimSpeed = 20 } },
    { Name = "Reinforced Tank", Type = "Tank", Rarity = "Rare", Weight = 30, Bonus = { MaxOxygen = 200 } },
    { Name = "Carbon Fiber Flippers", Type = "Flippers", Rarity = "Rare", Weight = 30, Bonus = { SwimSpeed = 30 } },
    { Name = "Atlantean Rebreather", Type = "Tank", Rarity = "Legendary", Weight = 10, Bonus = { MaxOxygen = 500 } },
    { Name = "Motorized Sea Scooter", Type = "Flippers", Rarity = "Legendary", Weight = 10, Bonus = { SwimSpeed = 50 } },
}

-- Calculate total weight
local totalWeight = 0
for _, item in ipairs(GearPool) do
    totalWeight += item.Weight
end

local rng = Random.new()

-- Handle Roll Request securely on the server
GachaRollRemote.OnServerInvoke = function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return false, "Error checking coins" end
    
    local coins = leaderstats:FindFirstChild("Coins")
    if coins.Value < ROLL_COST then
        return false, "Not enough coins!"
    end

    -- Deduct Coins securely
    coins.Value -= ROLL_COST

    -- Perform Roll
    local roll = rng:NextInteger(1, totalWeight)
    local currentWeight = 0
    local wonItem = nil

    for _, item in ipairs(GearPool) do
        currentWeight += item.Weight
        if roll <= currentWeight then
            wonItem = item
            break
        end
    end

    if wonItem then
        -- Add to Inventory
        InventoryManager.AddItem(player, InventoryManager.ItemTypes.Gear, wonItem)
        print(player.Name .. " rolled a " .. wonItem.Rarity .. " " .. wonItem.Name .. "!")
        return true, wonItem
    end

    return false, "Roll failed"
end
