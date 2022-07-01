--create the class
local spawner_slime = Class(function(self, inst)
	self.inst = inst
	self.minprefs = {}

    --wait for a player to join the wotld
    inst:ListenForEvent("ms_playerjoined", function(src, player)

        --get the player's coords and count all slime spawners nearby the player
        local x, y, z = player.Transform:GetWorldPosition()
        local slime_spawner = TheSim:FindEntities(x, y, z, 1200, {"slime_spawner"})

		--delete all of the slime spawners
		for k,v in pairs(slime_spawner) do
			v:Remove()
		end

		--spawn in new slime spawner on all of the players
		for i, v in ipairs(AllPlayers) do
			--get the player pos and the distance of them from the slime
			local vx, vy, vz = v.Transform:GetWorldPosition()
			SpawnPrefab("slime_spawner").Transform:SetPosition(vx, vy, vz)
		end

    end)
end)

return spawner_slime
