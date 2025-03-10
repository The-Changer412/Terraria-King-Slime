--get the basic behaviours
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/standstill"

--create the brain
local king_slime_brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)

    --set the properties for the brain
    self._ANIM_FRAME_MAX = 3
    self._ANIM_FRAME_STATE = 0
    self._ATTACK_DIST = 2.3
    self._DAMAGE_DIST = 2.0
    self._DAMAGE = 105
    self._JUMP_SPD = 11.5
    self._JUMP_TIME_MAX = 1
    self._WEAK_SLIME_SPAWNER_MAX = 45
    self._weak_slime_spawner = self._WEAK_SLIME_SPAWNER_MAX
    self._wander_time = 0
    self._is_jump_cooldown = false
    self._jump_time = self._JUMP_TIME_MAX
    self._jump_up = true
    self._state_switch = math.random(1, 80)
    self._state = "idle"
    self._closest_dis = nil
    self._closest_player = nil
    self._dropped_loot = false
end)

--tell the brain what to do when started
function king_slime_brain:OnStart()

    --no idea what this does, but its probably needed
    local root = PriorityNode(
    {
        --switch state to dead when it died
        WhileNode(function()
            if self.inst.components.health.currenthealth <= 0 then
                self._state = "dead"
            end
        end),

        --function to manually animate and loop since it normal way of doing it didnt work for me
        WhileNode(function()
            --make it where it will only animate when alive
            if self._state ~= "dead" then
                --manually count and loop the animation frames
                if self._ANIM_FRAME_STATE < self._ANIM_FRAME_MAX then
                    self._ANIM_FRAME_STATE = self._ANIM_FRAME_STATE + 1
                else
                    self._ANIM_FRAME_STATE = 0
                end

                --play the correct animation
                if self._jump_time <= 0 and self._jump_up == true then
                    self.inst.AnimState:SetBank("king_slime_4")
                    self.inst.AnimState:SetBuild("king_slime_4")
                    self.inst.AnimState:PlayAnimation("idle")
                    self._ANIM_FRAME_STATE = 0
                else
                    self.inst.AnimState:SetBank("king_slime_" .. tostring(self._ANIM_FRAME_STATE))
                    self.inst.AnimState:SetBuild("king_slime_" .. tostring(self._ANIM_FRAME_STATE))
                    self.inst.AnimState:PlayAnimation("idle")
                end
            end
        end),

        --manually drop the loot on death
        WhileNode(function()
            if self._state == "dead" and self._dropped_loot == false then
                self.inst.components.lootdropper:DropLoot(self.inst:GetPosition())
                self._dropped_loot = true
            end
        end),

        -- make the slime see how far away the players are and decide what to do next
        WhileNode(function()
            --set the distance
            local dis = nil

            --make it only get the distance when alive
            if self._state ~= "dead" then
                --get the slime pos
                local x, y, z = self.inst.Transform:GetWorldPosition()

                --loop over all of the players to see which one is the closest
                for i, v in ipairs(AllPlayers) do
                    --get the player pos and the distance of them from the slime
                    local vx, vy, vz = v.Transform:GetWorldPosition()
                    dis = math.sqrt((vx - x)^2 + (vz - z)^2)

                    --if the player is the closest then reset the target
                    if self._closest_dis == nil or self._closest_dis > dis then
                        self._closest_dis = dis
                        self._closest_player = v
                    end
                end

                --only switch state when not on jump cooldown
                if self._is_jump_cooldown == false then
                    --check to see to chase them or to attack them
                    if self._ATTACK_DIST >= dis then
                        self._state = "attack"
                    else
                        if self._state == "attack" then
                            --first check to see if the slime is up in the air before switching
                            if self._jump_up == false and self._jump_time <=0 then
                                self._state = "chase"
                                self._jump_time =self._JUMP_TIME_MAX
                                self._jump_up = true

                                --since the slime just landed, it should do damage
                                local x, y, z = self.inst.Transform:GetWorldPosition()
                                --loop over all of the players to see which one is the closest
                                for i, v in ipairs(AllPlayers) do
                                    --get the player pos and the distance of them from the slime
                                    local vx, vy, vz = v.Transform:GetWorldPosition()
                                    local dis = math.sqrt((vx - x)^2 + (vz - z)^2)
                                    --if the player is the closest then damage it
                                    if self._DAMAGE_DIST > dis then
                                        v.components.combat:GetAttacked(self.inst, self._DAMAGE)
                                    end
                                end

                                --start the jump cooldown
                                self._state = "idle"
                                self._is_jump_cooldown = true
                                self._state_switch = 2
                            end
                        else
                            self._state = "chase"
                            self._jump_time = self._JUMP_TIME_MAX
                            self._jump_up = true
                        end
                    end
                    self._wander_time = 0
                end
            end
        end),

        -- WhileNode(function()
        --     self._state = "idle"
        -- end),

        --slime attack
        WhileNode(function()
            if self._state == "attack" then
                --stop any movement
                self._wander_time = 0
                self._closest_player = nil
                self._closest_dis = nil
                self.inst.components.combat:SetTarget(nil)
                self.inst.components.locomotor:Stop()

                --jump cycle
                if self._is_jump_cooldown == false then
                    if self._jump_time > 0 then
                        --check to see if the slime should move up or down
                        if self._jump_up then
                            self.inst.Physics:SetMotorVel(0, self._JUMP_SPD, 0)
                        else
                            self.inst.Physics:SetMotorVel(0, -self._JUMP_SPD, 0)
                        end
                        --countdown the jump timer
                        self._jump_time = self._jump_time -1
                    else
                        --reset the jump timer and move the opposide way
                        self._jump_time = self._JUMP_TIME_MAX
                        if self._jump_up == false then
                            self._jump_up = true
                            --if the slime just landed, do damage to all players near him
                            local x, y, z = self.inst.Transform:GetWorldPosition()
                            --loop over all of the players to see which one is the closest
                            for i, v in ipairs(AllPlayers) do
                                --get the player pos and the distance of them from the slime
                                local vx, vy, vz = v.Transform:GetWorldPosition()
                                local dis = math.sqrt((vx - x)^2 + (vz - z)^2)
                                --if the player is the closest then damage it
                                if self._DAMAGE_DIST > dis then
                                    v.components.combat:GetAttacked(self.inst, self._DAMAGE)
                                end
                            end
                            --make the slime attack on cooldown
                            self._state = "idle"
                            self._is_jump_cooldown = true
                            self._state_switch = 2
                        else
                            self._jump_up = false
                        end
                    end
                end
            end
        end),

        --make the slime not move when idle
        WhileNode(function()
            if self._state == "idle" then
                --stop any movement
                self._wander_time = 0
                self._closest_player = nil
                self._closest_dis = nil
                self.inst.components.combat:SetTarget(nil)
                self.inst.components.locomotor:Stop()

                --check if the jump attack is on cooldown and count it down
                if self._is_jump_cooldown == true then
                    if self._state_switch > 0 then
                        self._state_switch = self._state_switch -1
                    else
                        self._state = "chase"
                        self._is_jump_cooldown = false
                        self._jump_time = self._JUMP_TIME_MAX
                        self._jump_up = true
                    end
                end
            end
        end),

        --chase after the target
        WhileNode(function()
            if self._state == "chase" then
                --get the combat
                local combat = self.inst.components.combat

                --set the closest player as the target and chase them
                if self._closest_player ~= nil and self._closest_player:HasTag("playerghost") == false then
                    --set the target
                    combat:SetTarget(self._closest_player)

                    --get the positon of the target and the angle
                    local target_position = Point(combat.target.Transform:GetWorldPosition())
                    local angle = self.inst:GetAngleToPoint(target_position)

                    --face the target and chase after them
                    self.inst.Transform:SetRotation(angle)
                    self.inst.components.locomotor:RunForward()
                else
                    self._closest_player = nil
                    self._closest_dis = nil
                    combat:SetTarget(nil)
                    self.inst.components.locomotor:Stop()
                end
            end
        end),

        --spawn in a weak slime nearby king slime in a timer
        WhileNode(function()
            --check to see if king slime is not dead and not in the air
            if self._state ~= "dead" and self._jump_time > 0 then
                if self._weak_slime_spawner > 0 then
                    self._weak_slime_spawner = self._weak_slime_spawner - 1
                else
                    local vx, vy, vz = self.inst.Transform:GetWorldPosition()
                    local rx = math.random(-1.75 ,1.75)
                    local rz = math.random(-1.75 ,1.75)
                    SpawnPrefab("weak_slime").Transform:SetPosition(vx+rx, vy, vz+rz)
                    self._weak_slime_spawner = self._WEAK_SLIME_SPAWNER_MAX
                end
            end
        end),


    }, .25)

    --no idea what this does, but i think it attaches the root to the brain
    self.bt = BT(self.inst, root)

end

--give the brain back
return king_slime_brain
