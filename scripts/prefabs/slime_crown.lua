 local assets =
 {
     Asset("ANIM", "anim/slime_crown.zip"),
     Asset("ATLAS", "images/inventoryimages/slime_crown.xml"),
     Asset("IMAGE", "images/inventoryimages/slime_crown.tex"),
 }

 local prefabs =
 {
 }

 local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    anim:SetBank("slime_crown")
    anim:SetBuild("slime_crown")
    anim:PlayAnimation("idle")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "slime_crown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/slime_crown.xml"

    return inst
end

return Prefab("common/inventory/slime_crown", fn, assets, prefabs)
