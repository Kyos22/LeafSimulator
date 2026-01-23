--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)
local Enums = require(script.Parent.Parent.Enums)
local Rarity = Enums.Rarity
local Scale = Enums.Scale
local CONSTANT = require(ReplicatedStorage.Shared.CONSTANT)

local Id = {
	OwO_Leaf_Common = "OwO_Leaf_Common",
    OwO_Leaf_Uncommon = "OwO_Leaf_Uncommon",
	OwO_Leaf_Rare = "OwO_Leaf_Rare",
	OwO_Leaf_Epic = "OwO_Leaf_Epic",
	OwO_Leaf_Legend = "OwO_Leaf_Legend",
}

local Data = {
	[Id.OwO_Leaf_Common] = {
		Order = 1,
		Name = "Leaf",
		Scale = Scale.Small,
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.01,
		Rate = 0.6,
		Area = CONSTANT.TAG.AREA.OWO_LEAF,
		Health = 5,
	},
    [Id.OwO_Leaf_Uncommon] = {
		Order = 2,
		Name = "Leaf",
		Scale = Scale.Small,
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.02,
		Rate = 0.3,
		Area = CONSTANT.TAG.AREA.OWO_LEAF,
		Health = 5,
	}, 
	[Id.OwO_Leaf_Rare] = {
		Order = 3,
		Name = "Leaf",
		Scale = Scale.Small,
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.03,
		Rate = 0.15,
		Area = CONSTANT.TAG.AREA.OWO_LEAF,
		Health = 5,
	}, 
	[Id.OwO_Leaf_Epic] = {
		Order = 4,
		Name = "Leaf",
		Scale = Scale.Small,
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.04,
		Rate = 0.1,
		Area = CONSTANT.TAG.AREA.OWO_LEAF,
		Health = 5,
	}, 
	[Id.OwO_Leaf_Legend] = {
		Order = 5,
		Name = "Leaf",
		Scale = Scale.Small,
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.05,
		Rate = 0.05,
		Area = CONSTANT.TAG.AREA.OWO_LEAF,
		Health = 5,
	}, 
} :: { [string]: Enums.LeafType }

local module = {}
module.Id = Id
module.Data = Data

function module.Get(id: string)
	return Data[id]
end

Sift.Dictionary.freezeDeep(module)

return module
