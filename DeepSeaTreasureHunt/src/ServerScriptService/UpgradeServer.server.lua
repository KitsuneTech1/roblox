local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatManager = require(script.Parent:WaitForChild("StatManager"))

local UpgradeStatRemote = Instance.new("RemoteFunction")
UpgradeStatRemote.Name = "UpgradeStatRequest"
UpgradeStatRemote.Parent = ReplicatedStorage

local GetStatsRemote = Instance.new("RemoteFunction")
GetStatsRemote.Name = "GetStatsRequest"
GetStatsRemote.Parent = ReplicatedStorage

GetStatsRemote.OnServerInvoke = function(player)
    local stats = StatManager.GetStats(player)
    if not stats then return nil end

    -- Return the current levels AND the cost for the next levels
    return {
        SwimSpeedLevel = stats.SwimSpeedLevel,
        SwimSpeedCost = StatManager.GetUpgradeCost("SwimSpeed", stats.SwimSpeedLevel),
        
        LuckLevel = stats.LuckLevel,
        LuckCost = StatManager.GetUpgradeCost("Luck", stats.LuckLevel),
        
        MaxOxygenLevel = stats.MaxOxygenLevel,
        MaxOxygenCost = StatManager.GetUpgradeCost("MaxOxygen", stats.MaxOxygenLevel),
    }
end

UpgradeStatRemote.OnServerInvoke = function(player, statName)
    local success, newLevelOrError = StatManager.UpgradeStat(player, statName)
    
    if success then
        -- Update the player's physical Values so local scripts can read them instantly
        local valueObj = player:FindFirstChild(statName .. "Level")
        if not valueObj then
            valueObj = Instance.new("IntValue")
            valueObj.Name = statName .. "Level"
            valueObj.Parent = player
        end
        valueObj.Value = newLevelOrError
        
        -- Also update their max oxygen immediately if that's what they bought
        if statName == "MaxOxygen" and player.Character then
            local maxOxy = player.Character:FindFirstChild("MaxOxygen")
            local currentOxy = player.Character:FindFirstChild("Oxygen")
            if maxOxy and currentOxy then
                local newMax = 100 + (newLevelOrError - 1) * 20
                maxOxy.Value = newMax
                currentOxy.Value = newMax -- refill them on upgrade
            end
        end
    end
    
    return success, newLevelOrError
end
