--!strict
local LeafSystem = require(script.leaf)
local AreaSystem = require(script.Area)

local leafSystem = LeafSystem.new({})
---@diagnostic disable-next-line
local areaSystem = AreaSystem.new({})

areaSystem:Initialize(leafSystem)

local spawnParts = areaSystem:GetSpawnLeafParts()

for _, part in ipairs(spawnParts) do
    leafSystem:SpawnLeaf(part)
end