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
function module:_Setup() 
    
end

function module:_Start() 

end

return module

