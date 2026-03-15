local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		-- Give player a test tool
		local tool = Instance.new("Tool")
		tool.Name = "TestSword"
		
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(1, 1, 1)
		handle.Parent = tool
		
		tool.Parent = player.Backpack
	end)
end)

print("Hello world, from server!")
