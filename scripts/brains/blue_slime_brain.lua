--get the basic behaviours
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/standstill"

--set the properties for the animation frame
local ANIM_FRAME_MAX = 1
local ANIM_FRAME_STATE = 0

--create the brain
local blue_slime_brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--tell the brain what to do when started
function blue_slime_brain:OnStart()

    --no idea what this does, but its probably needed
    local root = PriorityNode(
    {
        --function to manually animate and loop since it normal way of doing it didnt work for me
        WhileNode(function()
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
            end)
    }, .25)

    --no idea what this does, but i think it attaches the root to the brain
    self.bt = BT(self.inst, root)

end

--give the brain back
return blue_slime_brain
