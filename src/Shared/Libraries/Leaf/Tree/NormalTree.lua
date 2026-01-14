--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)
local Enums = require(script.Parent.Parent.Enums)
local Rarity = Enums.Rarity

local Id = {
	Normal_Leaf_Common = "Normal_Leaf_Common",
    Normal_Leaf_Uncommon = "Normal_Leaf_Uncommon",
	Normal_Leaf_Rare = "Normal_Leaf_Rare",
	Normal_Leaf_Epic = "Normal_Leaf_Epic",
	Normal_Leaf_Legend = "Normal_Leaf_Legend",
}

local Data = {
	[Id.Normal_Leaf_Common] = {
		Order = 1,
		Name = "Leaf",
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.01,
		Rate = 0.6,
	},
    [Id.Normal_Leaf_Uncommon] = {
		Order = 2,
		Name = "Leaf",
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.02,
		Rate = 0.3,
	}, 
	[Id.Normal_Leaf_Rare] = {
		Order = 3,
		Name = "Leaf",
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.03,
		Rate = 0.15,
	}, 
	[Id.Normal_Leaf_Epic] = {
		Order = 4,
		Name = "Leaf",
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.04,
		Rate = 0.1,
	}, 
	[Id.Normal_Leaf_Legend] = {
		Order = 5,
		Name = "Leaf",
		Image = "",
		Rarity = Rarity.Common,
		Weight = 0.05,
		Rate = 0.05,
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
