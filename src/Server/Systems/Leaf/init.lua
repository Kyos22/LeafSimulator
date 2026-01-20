--!strict

--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LeafSystem = require(script.leaf)
local AreaSystem = require(script.Area)

local leafSystem = LeafSystem.new({})
local areaSystem = AreaSystem.new({})
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)

--
export type APIsType = {}

local module = {
    
} :: APIsType & Yumi.System

--// Yumi

--// APIs
function module:_Setup() end

function module:_Start() 
    areaSystem:Initialize(leafSystem)
end


return module
