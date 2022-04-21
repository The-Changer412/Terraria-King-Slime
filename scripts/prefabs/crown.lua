-- load in the assets
local assets =
{
    Asset("ANIM", "anim/crown.zip"),
    Asset("ATLAS", "images/inventoryimages/crown.xml"),
    Asset("IMAGE", "images/inventoryimages/crown.tex"),
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
    anim:SetBank("crown")
    anim:SetBuild("crown")
    anim:PlayAnimation("idle")

    -- make the item show up in the inventory
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "crown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/crown.xml"

    return inst
end

-- load in the item
return Prefab("common/inventory/crown", fn, assets, prefabs)
