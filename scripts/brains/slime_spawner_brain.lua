local slime_spawner_brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._SLIME_SPAWN_RADIUS_MAX = 11
    self._SLIME_SPAWN_RADIUS_MIN = 5
    self._SLIME_SPAWNER_TIMER_MAX = 40
    self._SLIME_SPAWNER_TIMER_MIN = 18
    self._START_DELAY_MAX = 8
    self._start_delay = self._START_DELAY_MAX
    self._slime_spawner_max = 0
    self._slime_spawner = self._slime_spawner_max
    self._talk_spawn = false
    self._talk_despawn = false

end)


function slime_spawner_brain:OnStart()

    local root = PriorityNode(
    {
        WhileNode(function()
            --teleport the spawner to each player's position
            for i, v in ipairs(AllPlayers) do
                self.inst.Transform:SetPosition(v.Transform:GetWorldPosition())
            end

            --check the terrarium to see if it is on the floor and it is not night time
            for k,v in pairs(Ents) do
                if v.prefab == "terrarium" then
                    if v.components.inventoryitem.owner == nil and TheWorld.state.isday == true then
                        --add in a delay for the slime spawner
                        if self._start_delay < 0 then
                            --tell the playrs that slimes are spawning
                            if self._talk_spawn == false then
                                TheNet:Announce("The slimes are coming into this world.")
                                self._talk_spawn = true
                                self._talk_despawn = false
                            end

                            --check if the timer is done
                            if self._slime_spawner < 0 then
                                --make the slimne spawn in a random positon inside the radius of the terrarium
                                local vx, vy, vz = v.Transform:GetWorldPosition()
                                local rx = math.random(self._SLIME_SPAWN_RADIUS_MIN, self._SLIME_SPAWN_RADIUS_MAX)
                                local rz = math.random(self._SLIME_SPAWN_RADIUS_MIN, self._SLIME_SPAWN_RADIUS_MAX)
                                rx = rx * math.random(-1, 1)
                                rz = rz * math.random(-1, 1)
                                SpawnPrefab("slime").Transform:SetPosition(vx+rx, vy, vz+rz)

                                --reset the timer with a random cooldown
                                self._slime_spawner_max = math.random(self._SLIME_SPAWNER_TIMER_MIN, self._SLIME_SPAWNER_TIMER_MAX)
                                self._slime_spawner = self._slime_spawner_max
                            else
                                --countdown the timer
                                self._slime_spawner = self._slime_spawner - 1
                            end
                            self._start_delay = self._START_DELAY_MAX
                        else
                            self._start_delay = self._start_delay -1
                        end


                    else
                        --tell the playrs taht slimes stop spawning
                        if self._talk_despawn == false and self._talk_spawn == true then
                            TheNet:Announce("The slimes are no longer coming into this world.")
                            self._talk_despawn = true
                            self._talk_spawn = false
                        end

                        --reset the stats
                        self._start_delay = self._START_DELAY_MAX
                        self._slime_spawner_max = 0
                        self._slime_spawner = self._slime_spawner_max
                    end
                end
            end
        end)
    }, .25)

    --no idea what this does, but i think it attaches the root to the brain
    self.bt = BT(self.inst, root)
end

--give the brain back
return slime_spawner_brain
