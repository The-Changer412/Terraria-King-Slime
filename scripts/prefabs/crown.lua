 local assets = {
     Asset("ATLAS", "images/inventoryimages/crown.xml"),
     Asset("IMAGE", "images/inventoryimages/crown.tex"),
 }

 local prefabs =
 {
 }

 local function fn()
     local inst = CreateEntity()
     local trans = inst.entity:AddTransform()

    MakeInventoryPhysics(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "crown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/crown.xml"

    return inst
end

return Prefab("crown", fn, assets, prefabs)
