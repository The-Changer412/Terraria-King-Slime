-- point to where the prefabs are at to load them in
PrefabFiles = {
    "crown",
    "gel",
    "slime_crown",
    "slime",
    "slime_spawner",
    "king_slime",
    "weak_slime",
    "royal_gel",
    "slimy_jerky"
}

-- get the global string and ingredient var
local G = GLOBAL
local STRINGS = G.STRINGS
local Ingredient = G.Ingredient


-- add in the crafting recipe for the crown
local crown = AddRecipe(
    "crown", -- name
    { Ingredient("goldnugget", 5) }, -- ingredients
    G.RECIPETABS.WAR, -- tab
    G.TECH.NONE, -- crafting level
    nil, -- does it need to be placed?
    nil, -- minimum spacing between the objects
    nil, -- can the player not permanently unlock the recipe?
    1, -- the amount to give
    nil, -- can only certain character can make this?
    "images/inventoryimages/crown.xml", --atlas
    "crown.tex" -- image
)

-- add in the crafting recipe for the slime crown
local slime_crown = AddRecipe(
    "slime_crown",  -- name
    { Ingredient("crown", 1, "images/inventoryimages/crown.xml", "crown.tex"), Ingredient("gel", 20, "images/inventoryimages/gel.xml", "gel.tex") }, -- ingredients
     G.RECIPETABS.WAR, -- tab
     G.TECH.NONE, -- crafting level
     nil, -- does it need to be placed?
     nil, -- minimum spacing between the objects
     nil, -- can the player not permanently unlock the recipe?
     1, -- the amount to give
     nil, -- can only certain character can make this?
     "images/inventoryimages/slime_crown.xml",  --atlas
     "slime_crown.tex" -- image
)

-- set the name, inspection quote, and the recipe description for the items
STRINGS.NAMES.GEL = "Gel"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GEL = "Ew, it's slimy."

STRINGS.NAMES.CROWN = "Crown"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CROWN = "It's too bad that it's too small to put on my head."
STRINGS.RECIPE_DESC.CROWN = "The crown is to small to put on your head."

STRINGS.NAMES.SLIME_CROWN = "Slime Crown"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SLIME_CROWN = "It looks like a king version of the small slimy creatures."
STRINGS.RECIPE_DESC.SLIME_CROWN = "I heard that this item will attract a certain creature."

STRINGS.NAMES.ROYAL_GEL = "Royal Gel"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROYAL_GEL = "This werid object is making slimes friendly with me when I have it on me."

STRINGS.NAMES.SLIMY_JERKY = "Slimey Jerky"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SLIMY_JERKY = "Ewww. Who would eat this?"

--attach the spawner_slime function to post initiation of the world
if STRINGS.NAMES.MIGRATION_PORTAL then
	AddPrefabPostInit("world", function(inst)
		if inst.ismastersim then
			inst:AddComponent("spawner_slime")
		end
	end)
else
	AddPrefabPostInit("forest", function(inst)
		if inst.ismastersim then
			inst:AddComponent("spawner_slime")
		end
	end)
end
