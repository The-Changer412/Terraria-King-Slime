--get the brain
local brain = require "brains/slime_brain"

--import the assets
local assets =
{
    Asset("ANIM", "anim/blue_slime_0.zip"),
    Asset("ANIM", "anim/blue_slime_1.zip"),
    Asset("ANIM", "anim/green_slime_0.zip"),
    Asset("ANIM", "anim/green_slime_1.zip"),
    Asset("ANIM", "anim/purple_slime_0.zip"),
    Asset("ANIM", "anim/purple_slime_1.zip"),
}

--import the prefabs
local prefabs =
{
    "gel"
}

local loot = {}

for i = 1, math.random(1, 3), 1 do
    table.insert(loot, "gel")
end

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

    --make it where the slime wont slide away when being pushed
    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)

    -- set the movement state property
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 4

    -- set the health property
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(130)

    --set the loot property
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    -- set the combat property
    inst:AddComponent("combat")

    -- give it it's brain
    inst:SetBrain(brain)

    return inst

end

-- return the slime
return Prefab("slime", fn, assets, prefabs)
