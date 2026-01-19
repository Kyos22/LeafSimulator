--!strict
local LeafSystem = require(script.leaf)
local AreaSystem = require(script.Area)

local leafSystem = LeafSystem.new({})
local areaSystem = AreaSystem.new({})


areaSystem:Initialize(leafSystem)




--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)

--
export type APIsType = {}

local module = {} :: APIsType & Yumi.System

--// Yumi

--// APIs


return module
