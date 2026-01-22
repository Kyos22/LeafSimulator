--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)

export type WorldType = {
	Name: string,
	Image: string,
	Description: string,
}

local Id = {
	Beginner_World = "Beginner_World",
	Forest_World = "Forest_World",
	Desert_World = "Desert_World",
	Ice_World = "Ice_World",
	Volcano_World = "Volcano_World",
}

local Data = {
	[Id.Beginner_World] = {
		Name = "Beginner World",
		Image = "",
		Description = "The first world where new players learn the basics and begin their adventure.",
	},

	[Id.Forest_World] = {
		Name = "Forest World",
		Image = "",
		Description = "A mysterious forest filled with wild creatures, hidden paths, and ancient secrets.",
	},

	[Id.Desert_World] = {
		Name = "Desert World",
		Image = "",
		Description = "A vast desert land with scorching heat, sandstorms, and powerful enemies.",
	},

	[Id.Ice_World] = {
		Name = "Ice World",
		Image = "",
		Description = "A frozen realm of snow and ice where survival is difficult and enemies are relentless.",
	},

	[Id.Volcano_World] = {
		Name = "Volcano World",
		Image = "",
		Description = "A dangerous volcanic world filled with lava, fire monsters, and extreme challenges.",
	},
} :: { [string]: WorldType }

local module = {}
module.Id = Id
module.Data = Data

function module.Get(id: string): WorldType?
	return Data[id]
end

Sift.Dictionary.freezeDeep(module)

return module
