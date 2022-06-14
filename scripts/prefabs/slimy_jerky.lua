-- load in the assets
local assets =
{
    Asset("ANIM", "anim/slimy_jerky.zip"),
    Asset("ATLAS", "images/inventoryimages/slimy_jerky.xml"),
    Asset("IMAGE", "images/inventoryimages/slimy_jerky.tex"),
}

-- main function for the item
local function fn()
    -- initalize the the item entity,  transform, and animation state
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("meat")

    -- give the item physics
    MakeInventoryPhysics(inst)

    -- load in the animations
    anim:SetBank("slimy_jerky")
    anim:SetBuild("slimy_jerky")
    anim:PlayAnimation("idle")

    -- make the item show up in the inventory
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "slimy_jerky"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/slimy_jerky.xml"

    -- make the item inspectable
    inst:AddComponent("inspectable")

    --make the item stackable
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 20

    --make the item edible
    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.healthvalue = -3
    inst.components.edible.hungervalue = 75
    inst.components.edible.sanityvalue = -10

    --make the food slowly turn into rot
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    return inst
end

-- load in the item
return Prefab("slimy_jerky", fn, assets, prefabs)
