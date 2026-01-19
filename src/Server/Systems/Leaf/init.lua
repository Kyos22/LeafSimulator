--!strict
local LeafSystem = require(script.leaf)
local AreaSystem = require(script.Area)

local leafSystem = LeafSystem.new({})
local areaSystem = AreaSystem.new({})


areaSystem:Initialize(leafSystem)




