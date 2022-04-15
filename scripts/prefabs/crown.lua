 local assets =
 {
     Asset("ANIM", "anim/crown.zip"),
     Asset("ATLAS", "images/inventoryimages/crown.xml"),
     Asset("IMAGE", "images/inventoryimages/crown.tex"),
 }

 local prefabs =
 {
 }

 local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    anim:SetBank("crown")
    anim:SetBuild("crown")
    anim:PlayAnimation("idle")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "crown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/crown.xml"

    return inst
end

return Prefab("common/inventory/crown", fn, assets, prefabs)
