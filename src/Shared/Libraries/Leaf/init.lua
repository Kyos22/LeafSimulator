--!strict
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)

--// Modules
local Enums = require(script.Enums)
local Default = require(script.Leaf.Default)
local OwOLeaf = require(script.Leaf.OwOLeaf)

--// Constants & Enums
local Currency = Enums.Currency
local CurrencyVisual = Enums.CurrencyVisual

local Rarity = Enums.Rarity
local RarityColor = Enums.RarityColor

--// References
local Data = {
    Default = Default.Data,
    OwOLeaf = OwOLeaf.Data
}

--// APIs
local module = {}

module.Currency = Currency
module.CurrencyVisual = CurrencyVisual
module.Data = Data
module.Rarity = Rarity
module.RarityColor = RarityColor

Sift.Dictionary.freezeDeep(module)
return module
