--create the class
local spawner_slime = Class(function(self, inst)
	self.inst = inst
	self.minprefs = {}

    --wait for a player to join the wotld
    inst:ListenForEvent("ms_playerjoined", function(src, player)

        --get the player's coords and count all slime spawners nearby the player
        local x, y, z = player.Transform:GetWorldPosition()
        local slime_spawner = TheSim:FindEntities(x, y, z, 400, {"slime_spawner"})

        --if there isnt a slime spawner in the world, then spawn one in
        if #slime_spawner == 0 then
            SpawnPrefab("slime_spawner").Transform:SetPosition(x, y, z)
        end
    end)
end)

return spawner_slime
