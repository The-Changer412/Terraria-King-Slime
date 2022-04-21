-- load in the assets
local assets =
{
    Asset("ANIM", "anim/gel.zip"),
    Asset("ATLAS", "images/inventoryimages/gel.xml"),
    Asset("IMAGE", "images/inventoryimages/gel.tex"),
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

    return inst
end

-- load in the item
return Prefab("common/inventory/gel", fn, assets, prefabs)
