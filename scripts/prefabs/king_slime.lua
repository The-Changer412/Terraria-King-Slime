--get the brain
local brain = require "brains/king_slime_brain"

--import the assets
local assets =
{
    Asset("ANIM", "anim/king_slime_0.zip"),
    Asset("ANIM", "anim/king_slime_1.zip"),
    Asset("ANIM", "anim/king_slime_2.zip"),
    Asset("ANIM", "anim/king_slime_3.zip"),
    Asset("ANIM", "anim/king_slime_4.zip"),
}

--import the prefabs
local prefabs =
{
    "gel"
}

local loot = {}

for i = 1, math.random(5, 12), 1 do
    table.insert(loot, "gel")
end


--idk how this works. I just know that it's needed to play the eye of terror music.
local function PushMusic(inst)
    if ThePlayer == nil or inst:HasTag("INLIMBO") then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 60 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "eyeofterror" })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 64) then
        inst._playingmusic = false
    end
end

local function OnMusicDirty(inst)
    if not TheNet:IsDedicated() then
        if inst._musictask ~= nil then
            inst._musictask:Cancel()
        end
        inst._musictask = inst:DoPeriodicTask(1, PushMusic, 0.5)
    end
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

    --something that is needed for the music.
    inst._musicdirty = net_event(inst.GUID, "eyeofterror._musicdirty", "musicdirty")
    inst._playingmusic = false
    OnMusicDirty(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)

        return inst
    end

    --mark the slime as an emeny
    inst:AddTag("hostile")

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
    inst.components.health:SetMaxHealth(3000)

    --set the san
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE

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
return Prefab("king_slime", fn, assets, prefabs)
