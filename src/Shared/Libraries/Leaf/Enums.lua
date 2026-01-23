--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)

local Currency = {
	Basic = "Basic",
	Premium = "Premium",
}

local CurrencyVisual = {
	[Currency.Basic] = {
		Image = "",
		Color = Color3.fromRGB(255, 255, 255),
	},

	[Currency.Premium] = {
		Image = "",
		Color = Color3.fromRGB(255, 255, 255),
	},
} :: { [string]: { Image: string, Color: Color3 } }

local Rarity = {
	Common = "Common",
	Uncommon = "Uncommon",
	Rare = "Rare",
	Epic = "Epic",
	Legendary = "Legendary",
}

local Scale = {
	Small = 1,
	Medium = 1.5,
	Big = 2,
}

local RarityColor = {
	[Rarity.Common] = Color3.fromRGB(125, 125, 125),
	[Rarity.Uncommon] = Color3.fromRGB(93, 233, 111),
	[Rarity.Rare] = Color3.fromRGB(46, 93, 247),
	[Rarity.Epic] = Color3.fromRGB(198, 74, 255),
	[Rarity.Legendary] = Color3.fromRGB(255, 3, 3),
}

export type LeafType = {
    Order: number,
	Name: string,
	Scale: number,
    Image: string,
	Rarity: string,
	Weight: number,
	Rate: number,
	Area: string,
	Health: number,
}

export type AreaType = {
	Limited: number,
	Cooldown: number
}

local module = {}

module.Currency = Currency
module.CurrencyVisual = CurrencyVisual
module.Rarity = Rarity
module.RarityColor = RarityColor
module.Scale = Scale

Sift.Dictionary.freezeDeep(module)
return module
