--get the basic behaviours
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/standstill"

local types = {"blue", "green", "purple"}

--create the brain
local slime_brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)

    --set the properties for the brain
    self._TYPE = types[math.random(#types)]
    self._ANIM_FRAME_MAX = 1
    self._ANIM_FRAME_STATE = 0
    self._SEE_DIST = 9
    self._ATTACK_DIST = 1.5
    self._DAMAGE_DIST = 1.3
    self._DAMAGE = 20
    self._JUMP_SPD = 11.5
    self._JUMP_TIME_MAX = 1
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
function slime_brain:OnStart()

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
                self.inst.AnimState:SetBank(self._TYPE .. "_slime_" .. tostring(self._ANIM_FRAME_STATE))
                self.inst.AnimState:SetBuild(self._TYPE .. "_slime_" .. tostring(self._ANIM_FRAME_STATE))
                self.inst.AnimState:PlayAnimation("idle")
            end
        end),

        --manually drop the loot on death
        WhileNode(function()
            if self._state == "dead" and self._dropped_loot == false then
                self.inst.components.lootdropper:DropLoot(self.inst:GetPosition())
                self._dropped_loot = true
            end
        end),

        --make the slime see how far away the players are and decide what to do next
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
                    --check the distance to see if it's in the seeing distance
                    if self._SEE_DIST >= dis then
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
                                    self._state_switch = 3
                                end
                            else
                                self._state = "chase"
                                self._jump_time = self._JUMP_TIME_MAX
                                self._jump_up = true
                            end
                        end
                        self._wander_time = 0
                    else
                        --randomly pick to wander or to idle
                        if self._state ~= "wander" and self._state ~= "idle" then
                            if math.random(0, 1) == 0 then
                                self._state = "wander"
                            else
                                self._state = "idle"
                            end
                            --reset the targeting system
                            self._jump_time = self._JUMP_TIME_MAX
                            self._jump_up = true
                            self._closest_player = nil
                            self._closest_dis = nil
                            self.inst.components.combat:SetTarget(nil)
                            self.inst.components.locomotor:Stop()

                        --make it randomly switch between wander and idle after cooldown
                        elseif self._state == "wander" or self._state == "idle" then
                            if self._state_switch <= 0 then
                                if math.random(0, 1) == 0 then
                                    self._state = "wander"
                                else
                                    self._state = "idle"
                                end
                                self._state_switch = math.random(1, 80)
                            else
                                self._state_switch = self._state_switch - 1
                            end
                        end
                    end
                end
            end
        end),

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
                            self._state_switch = 3
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

        --make the slime wander around the world
        WhileNode(function()
            if self._state == "wander" then
                if self._wander_time <= 0 then
                    local angle = math.random(-180, 180)
                    self.inst.Transform:SetRotation(angle)
                    self.inst.components.locomotor:RunForward()
                    self._wander_time = math.random(2, 12)
                else
                    self._wander_time = self._wander_time - 1
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


    }, .25)

    --no idea what this does, but i think it attaches the root to the brain
    self.bt = BT(self.inst, root)

end

--give the brain back
return slime_brain
