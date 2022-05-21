--get the basic behaviours
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/standstill"

--set the properties for the animation frame
local ANIM_FRAME_MAX = 1
local ANIM_FRAME_STATE = 0
local SEE_DIST = 12
local ATTACK_DIST = 1
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
        WhileNode(function()
            if self.inst.components.health.currenthealth <= 0 then
                state = "dead"
            end
            print(state)
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

        -- make the slime see how far away the players are and decide what to do next
        WhileNode(function()
            --set the dis
            local dis = nil

            --make it only get the distance when alive
            if state ~= "dead" then
                -- get the slime pos
                local x, y, z = self.inst.Transform:GetWorldPosition()

                -- loop over all of the players to see which one is the closest
                for i, v in ipairs(AllPlayers) do
                    -- get the player pos and the distance of them from the slime
                    local vx, vy, vz = v.Transform:GetWorldPosition()
                    dis = math.sqrt((vx - x)^2 + (vz - z)^2)

                    -- if the player is the closest then reset the target
                    if closest_dis == nil or closest_dis > dis then
                        closest_dis = dis
                        closest_player = v
                    end
                end

                if SEE_DIST >= dis then
                    if ATTACK_DIST >= dis then
                        state = "attack"
                    else
                        state = "chase"
                    end
                else
                    state = "wander"
                    closest_player = nil
                    self.inst.components.combat:SetTarget(nil)
                end
            end
        end),

        --chase after the target close enough
        WhileNode(function()
            --get the combat
            local combat = self.inst.components.combat

            -- set the closest player as the target and chase them
            if closest_player ~= nil then
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
                combat:SetTarget(nil)
                self.inst.components.locomotor:Stop()
            end
        end),


    }, .25)

    --no idea what this does, but i think it attaches the root to the brain
    self.bt = BT(self.inst, root)

end

--give the brain back
return blue_slime_brain
