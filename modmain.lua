-- point to where the prefabs are at to load them in
PrefabFiles = {
    "crown",
    "gel",
    "slime_crown",
    "slime",
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
    { Ingredient("crown", 1, "images/inventoryimages/crown.xml", "crown.tex"), Ingredient("gel", 10, "images/inventoryimages/gel.xml", "gel.tex") }, -- ingredients
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
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CROWN = "It's to bad that it's to small to put on my head."
STRINGS.RECIPE_DESC.CROWN = "The crown is to small to put on your head."

STRINGS.NAMES.SLIME_CROWN = "Slime Crown"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SLIME_CROWN = "It looks like a king version of the small slimy creatures."
STRINGS.RECIPE_DESC.SLIME_CROWN = "I heard that this item will attract a certain creature."
