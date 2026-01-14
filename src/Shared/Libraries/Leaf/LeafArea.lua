--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)
local Enums = require(script.Parent.Enums)

local Id = {
	Normal_Leaf = "Normal_Leaf",
	Special_Leaf = "Special_Leaf",
}

local Data = {
	[Id.Normal_Leaf] = {
		Limited = 100,
		Cooldown = 3,
	},
	[Id.Special_Leaf] = {
		Limited = 70,
		Cooldown = 5,
	},
} :: { [string]: Enums.AreaType }

local module = {}
module.Id = Id
module.Data = Data

function module.Get(id: string)
	return Data[id]
end

Sift.Dictionary.freezeDeep(module)

return module
