--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local Client = require(ReplicatedStorage.Shared.Network.Client)

--
export type APIsType = {}

local module = {} :: APIsType & Yumi.System

--// Yumi

--// APIs
module._Start = function()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Q then
            print("hihi") 
            Client.Tools.Click.Fire()
        end
    end)
end

return module
