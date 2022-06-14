-- load in the assets
local assets =
{
    Asset("ANIM", "anim/royal_gel.zip"),
    Asset("ATLAS", "images/inventoryimages/royal_gel.xml"),
    Asset("IMAGE", "images/inventoryimages/royal_gel.tex"),
}

-- main function for the item
local function fn()
    -- initalize the the item entity,  transform, and animation state
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("royal_gel")

    -- give the item physics
    MakeInventoryPhysics(inst)

    -- load in the animations
    anim:SetBank("royal_gel")
    anim:SetBuild("royal_gel")
    anim:PlayAnimation("idle")

    -- make the item show up in the inventory
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "royal_gel"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/royal_gel.xml"

    -- make the item inspectable
    inst:AddComponent("inspectable")

    return inst
end

-- load in the item
return Prefab("royal_gel", fn, assets, prefabs)
