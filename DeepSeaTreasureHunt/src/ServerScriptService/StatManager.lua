local Players = game:GetService("Players")

local StatManager = {}
StatManager.PlayerStats = {}

-- Base stats for a new player
local DEFAULT_STATS = {
    SwimSpeedLevel = 1,
    LuckLevel = 1,
    MaxOxygenLevel = 1,
}

local UPGRADE_COSTS = {
    SwimSpeed = { BaseCost = 500, Multiplier = 1.5 },
    Luck = { BaseCost = 1000, Multiplier = 2.0 },
    MaxOxygen = { BaseCost = 400, Multiplier = 1.4 }
}

Players.PlayerAdded:Connect(function(player)
    -- In a full game, we would load these from a DataStore.
    -- For now, default to level 1
    StatManager.PlayerStats[player.UserId] = {
        SwimSpeedLevel = DEFAULT_STATS.SwimSpeedLevel,
        LuckLevel = DEFAULT_STATS.LuckLevel,
        MaxOxygenLevel = DEFAULT_STATS.MaxOxygenLevel,
    }
end)

Players.PlayerRemoving:Connect(function(player)
    StatManager.PlayerStats[player.UserId] = nil
end)

function StatManager.GetStats(player)
    return StatManager.PlayerStats[player.UserId]
end

function StatManager.GetUpgradeCost(statName, currentLevel)
    local costData = UPGRADE_COSTS[statName]
    if not costData then return 999999 end
    
    -- Exponential cost scaling
    return math.floor(costData.BaseCost * math.pow(costData.Multiplier, currentLevel - 1))
end

function StatManager.UpgradeStat(player, statName)
    local stats = StatManager.PlayerStats[player.UserId]
    if not stats then return false, "No stats found" end
    
    local currentLevel = stats[statName .. "Level"]
    if not currentLevel then return false, "Invalid stat" end
    
    local cost = StatManager.GetUpgradeCost(statName, currentLevel)
    
    -- Check coins
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return false, "Error checking coins" end
    
    local coins = leaderstats:FindFirstChild("Coins")
    if coins.Value < cost then
        return false, "Not enough coins!"
    end
    
    -- Purchase successful
    coins.Value -= cost
    stats[statName .. "Level"] = currentLevel + 1
    
    print(player.Name .. " upgraded " .. statName .. " to Level " .. stats[statName .. "Level"] .. "!")
    return true, stats[statName .. "Level"]
end

return StatManager
