-- load in the assets
local assets =
{
    Asset("ANIM", "anim/slime_crown.zip"),
    Asset("ATLAS", "images/inventoryimages/slime_crown.xml"),
    Asset("IMAGE", "images/inventoryimages/slime_crown.tex"),
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
    anim:SetBank("slime_crown")
    anim:SetBuild("slime_crown")
    anim:PlayAnimation("idle")

    -- make the item show up in the inventory
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "slime_crown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/slime_crown.xml"

    -- make the item inspectable
    inst:AddComponent("inspectable")

    return inst
end

-- load in the item
return Prefab("common/inventory/slime_crown", fn, assets, prefabs)
