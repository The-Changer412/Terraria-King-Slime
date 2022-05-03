--get the brain
local brain = require "brains/blue_slime_brain"

--import the assets
local assets =
{
    Asset("ANIM", "anim/blue_slime_0.zip"),
    Asset("ANIM", "anim/blue_slime_1.zip"),
}

--import the prefabs
local prefabs =
{
    "gel"
}

-- main function of the entity
local function fn()
    --create the important properties for the entity
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    local dync = inst.entity:AddDynamicShadow()
    local network = inst.entity:AddNetwork()

    --give the entity physics
    MakeCharacterPhysics(inst, 10, 0.5)

    --set the size of the entity and make it look in four directons
    dync:SetSize(1.0, 0.5)
    trans:SetFourFaced()

    -- no idea what this part does
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- set the movement state properties
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 8

    -- set the health properties
    inst:AddComponent("health")
    -- inst.components.health:SetMaxHealth(200)
    inst.components.health:SetMaxHealth(1)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"gel"})

    -- set the combat properties
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(10)
    inst.components.combat:SetAttackPeriod(1)
    -- inst.components.combat:SetRetargetFunction(3, retargetfn)

    -- give it it's brain
    inst:SetBrain(brain)

    return inst

end

-- return the slime
return Prefab("blue_slime", fn, assets, prefabs)
