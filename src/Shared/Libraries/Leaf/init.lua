--!strict
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)

--// Modules
local Enums = require(script.Enums)

--// Constants & Enums
local Currency = Enums.Currency
local CurrencyVisual = Enums.CurrencyVisual

local Rarity = Enums.Rarity
local RarityColor = Enums.RarityColor

--// References

local data = {
    
}


--// APIs
local module = {}

module.Currency = Currency
module.CurrencyVisual = CurrencyVisual

module.Rarity = Rarity
module.RarityColor = RarityColor

Sift.Dictionary.freezeDeep(module)
return module
