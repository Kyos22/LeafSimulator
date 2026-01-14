--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local ProfileTemplate = require(ReplicatedStorage.Shared.Libraries.Profile.Template)
---->> Network
local Client = require(ReplicatedStorage.Shared.Network.Client)
---->> Observer
local ProfileObserver = require(ReplicatedStorage.Controllers.Observers.Profile)
--// Variables
local Profile: ProfileTemplate.Profile
--// Type
export type Profile = ProfileTemplate.Profile
--
export type APIsType = {
    Get: () -> Profile?,
    GetAsync: () -> Profile?
}

local module = {} :: APIsType & Yumi.System

--// Yumi
module._Start = function()
    Client.Player_Update_Profile.On(function(data: unknown)
        Profile = data :: Profile
        ProfileObserver.Fire(ProfileObserver.Event.Updated, {
            Data = Profile
        } :: ProfileObserver.UpdatedEventArgs)
    end)

    Profile = Client.Get_Profile.Call():Await() :: Profile
end
--// APIs
module.Get = function()
    return Profile
end
module.GetAsync = function()
    if not Profile then
        Profile = Client.Get_Profile.Call(true):Await() :: Profile
    end
    return Profile
end

return module
