local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminRemote = ReplicatedStorage:WaitForChild("AdminRemote")

AdminRemote.OnServerEvent:Connect(function(player, action, value)
	-- Trusting the client as requested for testing ("i'll take it out before we deploy")
	
	if action == "AddCoins" then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			if coins then
				coins.Value += (tonumber(value) or 1000)
				print("Admin Server: Added coins to " .. player.Name)
			end
		end
	elseif action == "SetSpeed" then
		local char = player.Character
		local humanoid = char and char:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = tonumber(value) or 16
			print("Admin Server: Set speed for " .. player.Name)
		end
	elseif action == "GodMode" then
		local char = player.Character
		local humanoid = char and char:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.MaxHealth = math.huge
			humanoid.Health = math.huge
			print("Admin Server: Enabled God Mode for " .. player.Name)
		end
	end
end)
