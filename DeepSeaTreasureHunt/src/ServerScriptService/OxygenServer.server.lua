local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BASE_OXYGEN = 100 -- 100 seconds of air
local OXYGEN_DEPLETION_RATE = 1 -- subtracts 1 oxygen per second

Players.PlayerAdded:Connect(function(player)
    -- Fire every time the player spawns
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- Create oxygen values on the character
        local oxygen = Instance.new("NumberValue")
        oxygen.Name = "Oxygen"
        oxygen.Value = BASE_OXYGEN
        oxygen.Parent = character
        
        local maxOxygen = Instance.new("NumberValue")
        maxOxygen.Name = "MaxOxygen"
        maxOxygen.Value = BASE_OXYGEN
        maxOxygen.Parent = character

        -- Oxygen Loop
        local connection
        connection = RunService.Heartbeat:Connect(function(deltaTime)
            if not character.Parent or humanoid.Health <= 0 then
                connection:Disconnect()
                return
            end

            local depth = rootPart.Position.Y
            
            -- If player is underwater (Y coordinate is below 0)
            if depth < -5 then
                -- Base depletion rate + depth penalty (REDUCED FOR BETTER PROGRESSION)
                -- Depth penalty increases by 0.1 for every 100 studs deep (was 0.5)
                local depthPenalty = math.abs(depth) / 100 * 0.1
                local currentDepletionRate = OXYGEN_DEPLETION_RATE + depthPenalty
                
                oxygen.Value = math.max(0, oxygen.Value - (currentDepletionRate * deltaTime))
                
                -- Drowning damage
                if oxygen.Value <= 0 then
                    humanoid:TakeDamage(10 * deltaTime) -- Take 10 damage every second while drowning
                end
            else
                -- If they go above water, regenerate oxygen very quickly
                oxygen.Value = math.min(maxOxygen.Value, oxygen.Value + (BASE_OXYGEN * 0.5 * deltaTime))
            end
        end)
    end)
end)
