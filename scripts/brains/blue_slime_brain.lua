--get the basic behaviours
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/standstill"

--set the properties for the animation frame
local ANIM_FRAME_MAX = 1
local ANIM_FRAME_STATE = 0
local SEE_DIST = 9
local ATTACK_DIST = 1.5
local DAMAGE_DIST = 1.3
local DAMAGE = 12
local wander_time = 0
local is_jump_cooldown = false
local jump_time_max = 1
local jump_time = jump_time_max
local jump_spd = 11.5
local jump_up = true
local state_switch = math.random(1, 80)
local state = "idle"
local closest_dis = nil
local closest_player = nil
local dropped_loot = false

--create the brain
local blue_slime_brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--tell the brain what to do when started
function blue_slime_brain:OnStart()

    --no idea what this does, but its probably needed
    local root = PriorityNode(
    {
        --switch state to dead when it died
        WhileNode(function()
            if self.inst.components.health.currenthealth <= 0 then
                state = "dead"
            end
        end),

        --function to manually animate and loop since it normal way of doing it didnt work for me
        WhileNode(function()
            --make it where it will only animate when alive
            if state ~= "dead" then
                --manually count and loop the animation frames
                if ANIM_FRAME_STATE < ANIM_FRAME_MAX then
                    ANIM_FRAME_STATE = ANIM_FRAME_STATE + 1
                else
                    ANIM_FRAME_STATE = 0
                end

                --play the correct animation
                self.inst.AnimState:SetBank("blue_slime_" .. tostring(ANIM_FRAME_STATE))
                self.inst.AnimState:SetBuild("blue_slime_" .. tostring(ANIM_FRAME_STATE))
                self.inst.AnimState:PlayAnimation("idle")
            end
        end),

        --manually drop the loot on death
        WhileNode(function()
            if state == "dead" and dropped_loot == false then
                self.inst.components.lootdropper:DropLoot(self.inst:GetPosition())
                dropped_loot = true
            end
        end),

        --make the slime see how far away the players are and decide what to do next
        WhileNode(function()
            --set the distance
            local dis = nil

            --make it only get the distance when alive
            if state ~= "dead" then
                --get the slime pos
                local x, y, z = self.inst.Transform:GetWorldPosition()

                --loop over all of the players to see which one is the closest
                for i, v in ipairs(AllPlayers) do
                    --get the player pos and the distance of them from the slime
                    local vx, vy, vz = v.Transform:GetWorldPosition()
                    dis = math.sqrt((vx - x)^2 + (vz - z)^2)

                    --if the player is the closest then reset the target
                    if closest_dis == nil or closest_dis > dis then
                        closest_dis = dis
                        closest_player = v
                    end
                end

                --only switch state when not on jump cooldown
                if is_jump_cooldown == false then
                    --check the distance to see if it's in the seeing distance
                    if SEE_DIST >= dis then
                        --check to see to chase them or to attack them
                        if ATTACK_DIST >= dis then
                            state = "attack"
                        else
                            if state == "attack" then
                                --first check to see if the slime is up in the air before switching
                                if jump_up == false and jump_time <=0 then
                                    state = "chase"
                                    jump_time = jump_time_max
                                    jump_up = true

                                    --since the slime just landed, it should do damage
                                    local x, y, z = self.inst.Transform:GetWorldPosition()
                                    --loop over all of the players to see which one is the closest
                                    for i, v in ipairs(AllPlayers) do
                                        --get the player pos and the distance of them from the slime
                                        local vx, vy, vz = v.Transform:GetWorldPosition()
                                        local dis = math.sqrt((vx - x)^2 + (vz - z)^2)
                                        --if the player is the closest then damage it
                                        if DAMAGE_DIST > dis then
                                            v.components.combat:GetAttacked(self.inst, DAMAGE)
                                        end
                                    end

                                    --start thr jump cooldown
                                    state = "idle"
                                    is_jump_cooldown = true
                                    state_switch = 3
                                end
                            else
                                state = "chase"
                                jump_time = jump_time_max
                                jump_up = true
                            end
                        end
                        wander_time = 0
                    else
                        --randomly pick to wander or to idle
                        if state ~= "wander" and state ~= "idle" then
                            if math.random(0, 1) == 0 then
                                state = "wander"
                            else
                                state = "idle"
                            end
                            --reset the targeting system
                            jump_time = jump_time_max
                            jump_up = true
                            closest_player = nil
                            closest_dis = nil
                            self.inst.components.combat:SetTarget(nil)
                            self.inst.components.locomotor:Stop()

                        --make it randomly switch between wander and idle after cooldown
                        elseif state == "wander" or state == "idle" then
                            if state_switch <= 0 then
                                if math.random(0, 1) == 0 then
                                    state = "wander"
                                else
                                    state = "idle"
                                end
                                state_switch = math.random(1, 80)
                            else
                                state_switch = state_switch - 1
                            end
                        end
                    end
                end
            end
        end),

        --slime attack
        WhileNode(function()
            if state == "attack" then
                --stop any movement
                wander_time = 0
                closest_player = nil
                closest_dis = nil
                self.inst.components.combat:SetTarget(nil)
                self.inst.components.locomotor:Stop()

                --jump cycle
                if is_jump_cooldown == false then
                    if jump_time > 0 then
                        --check to see if the slime should move up or down
                        if jump_up then
                            self.inst.Physics:SetMotorVel(0, jump_spd, 0)
                        else
                            self.inst.Physics:SetMotorVel(0, -jump_spd, 0)
                        end
                        --countdown the jump timer
                        jump_time = jump_time -1
                    else
                        --reset the jump timer and move the opposide way
                        jump_time = jump_time_max
                        if jump_up == false then
                            jump_up = true
                            --if the slime just landed, do damage to all players near him
                            local x, y, z = self.inst.Transform:GetWorldPosition()
                            --loop over all of the players to see which one is the closest
                            for i, v in ipairs(AllPlayers) do
                                --get the player pos and the distance of them from the slime
                                local vx, vy, vz = v.Transform:GetWorldPosition()
                                local dis = math.sqrt((vx - x)^2 + (vz - z)^2)
                                --if the player is the closest then damage it
                                if DAMAGE_DIST > dis then
                                    v.components.combat:GetAttacked(self.inst, DAMAGE)
                                end
                            end
                            --make the slime attack on cooldown
                            state = "idle"
                            is_jump_cooldown = true
                            state_switch = 3
                        else
                            jump_up = false
                        end
                    end
                end
            end
        end),

        --make the slime not move when idle
        WhileNode(function()
            if state == "idle" then
                --stop any movement
                wander_time = 0
                closest_player = nil
                closest_dis = nil
                self.inst.components.combat:SetTarget(nil)
                self.inst.components.locomotor:Stop()

                --check if the jump attack is on cooldown and count it down
                if is_jump_cooldown == true then
                    if state_switch > 0 then
                        state_switch = state_switch -1
                    else
                        state = "chase"
                        is_jump_cooldown = false
                        jump_time = jump_time_max
                        jump_up = true
                    end
                end
            end
        end),

        --make the slime wander around the world
        WhileNode(function()
            if state == "wander" then
                if wander_time <= 0 then
                    local angle = math.random(-180, 180)
                    self.inst.Transform:SetRotation(angle)
                    self.inst.components.locomotor:RunForward()
                    wander_time = math.random(2, 12)
                else
                    wander_time = wander_time - 1
                end
            end
        end),

        --chase after the target
        WhileNode(function()
            if state == "chase" then
                --get the combat
                local combat = self.inst.components.combat

                --set the closest player as the target and chase them
                if closest_player ~= nil and closest_player:HasTag("playerghost") == false then
                    --set the target
                    combat:SetTarget(closest_player)

                    --get the positon of the target and the angle
                    local target_position = Point(combat.target.Transform:GetWorldPosition())
                    local angle = self.inst:GetAngleToPoint(target_position)

                    --face the target and chase after them
                    self.inst.Transform:SetRotation(angle)
                    self.inst.components.locomotor:RunForward()
                else
                    closest_player = nil
                    closest_dis = nil
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
return blue_slime_brain
