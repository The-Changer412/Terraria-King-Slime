--get the brain
local brain = require "brains/slime_spawner_brain"

-- main function of the entity
local function fn()
    --create the important properties for the entity
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()

    --give it a tag for countung
    inst:AddTag("slime_spawner")

    -- give it it's brain
    inst:SetBrain(brain)
    return inst
end

-- return the slime
return Prefab("slime_spawner", fn, nil, nil)
