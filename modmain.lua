local G = GLOBAL

PrefabFiles = {
    "crown",
    "gel",
    "slime_crown"
}

local STRINGS = G.STRINGS
local Ingredient = G.Ingredient

local crown = AddRecipe(
"crown",
{
    Ingredient("goldnugget", 5)
},
G.RECIPETABS.WAR,
G.TECH.NONE,
nil,
nil,
nil,
1,
nil,
"images/inventoryimages/crown.xml", "crown.tex"
)
crown.sortkey = -999

local slime_crown = AddRecipe(
    "slime_crown",
    {
        Ingredient("crown", 1, "images/inventoryimages/crown.xml", "crown.tex"),
        Ingredient("gel", 10, "images/inventoryimages/gel.xml", "gel.tex")
    },
     G.RECIPETABS.WAR,
     G.TECH.NONE,
     nil,
     nil,
     nil,
     1,
     nil,
     "images/inventoryimages/slime_crown.xml", "slime_crown.tex"
    )
slime_crown.sortkey = -998


STRINGS.NAMES.GEL = "Gel"
STRINGS.NAMES.CROWN = "Crown"
STRINGS.RECIPE_DESC.CROWN = "The crown is to small to put on your head."
STRINGS.NAMES.SLIME_CROWN = "Slime Crown"
STRINGS.RECIPE_DESC.SLIME_CROWN = "I heard that this item will attract a certain creature."
