--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)
local Enums = require(script.Parent.Enums)
local CONSTANT = require(ReplicatedStorage.Shared.CONSTANT)

local Id = {
	Default = CONSTANT.TAG.AREA.DEFAULT,
	OwoLeaf = CONSTANT.TAG.AREA.OWO_LEAF,
}

local Data = {
	[Id.Default] = {
		Limited = 100,
		Cooldown = 3,
	},
	[Id.OwoLeaf] = {
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
