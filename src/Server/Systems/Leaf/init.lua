--!strict
local LeafSystem = require(script.leaf)
local AreaSystem = require(script.Area)

local leafSystem = LeafSystem.new({})
local areaSystem = AreaSystem.new({})

while true do
    areaSystem:Initialize(leafSystem)
    task.wait(1)
end



