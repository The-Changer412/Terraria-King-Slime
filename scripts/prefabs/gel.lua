-- load in the assets
local assets =
{
    Asset("ANIM", "anim/gel.zip"),
    Asset("ATLAS", "images/inventoryimages/gel.xml"),
    Asset("IMAGE", "images/inventoryimages/gel.tex"),
 }

 prefabs =
 {
     "slime_crown",
    "slime"
 }

-- main function for the item
local function fn()
    -- initalize the the item entity,  transform, and animation state
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    -- give the item physics
    MakeInventoryPhysics(inst)

    -- load in the animations
    anim:SetBank("gel")
    anim:SetBuild("gel")
    anim:PlayAnimation("idle")

    -- make the item show up in the inventory
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gel"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gel.xml"

    -- make the item inspectable
    inst:AddComponent("inspectable")

    --make the item stackable
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40

    inst:AddComponent("useabletargeteditem")
    inst.components.useabletargeteditem:SetTargetPrefab("slime_crown")
    inst.components.useabletargeteditem:SetOnUseFn(function(item_use, item_used_on, player)
        --spawn in king slime (the slime is the placeholder) nearby the crown
        local vx, vy, vz = item_used_on.Transform:GetWorldPosition()
        local rx = math.random(-16, 16)
        local rz = math.random(-16, 16)
        SpawnPrefab("slime").Transform:SetPosition(vx+rx, vy, vz+rz)

        --make the player say something about it
        player.components.talker:Say("I hear something big coming this way.")

        --use the gel, and despawn the crown
        item_use.components.stackable:SetStackSize(item_use.components.stackable:StackSize() - 1)
        item_used_on:Remove()

        return true
    end)
    inst.components.useabletargeteditem:SetInventoryDisable(true)

    return inst
end

-- load in the item
return Prefab("common/inventory/gel", fn, assets, prefabs)
