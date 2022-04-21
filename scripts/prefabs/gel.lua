 local assets =
 {
     Asset("ANIM", "anim/gel.zip"),
     Asset("ATLAS", "images/inventoryimages/gel.xml"),
     Asset("IMAGE", "images/inventoryimages/gel.tex"),
 }

 local prefabs =
 {
 }

 local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    anim:SetBank("gel")
    anim:SetBuild("gel")
    anim:PlayAnimation("idle")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gel"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gel.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40

    return inst
end

return Prefab("common/inventory/gel", fn, assets, prefabs)
