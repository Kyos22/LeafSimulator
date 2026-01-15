--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services
local CollectionService = game:GetService("CollectionService")

--// Modules
local mapFolder = workspace:WaitForChild("Map")
local LeafArea = require(game.ReplicatedStorage.Shared.Libraries.Leaf.LeafArea)

----> Constructor
export type Config = {
    Part1: BasePart,
}

local function prototype(self, config: Config)
    ---->> Public
    self.Part1 = config.Part1

    ---->> Private
    type field = {
        tasks: { {Name: string, Thread: thread} },
        connections: { {Name: string, Connection: RBXScriptConnection} },
    }
    local _private = {
        tasks = {},
        connections = {},
    } :: field
    self._private = _private

    return self
end

---->> Public Properties
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {}
function module.constructors.new(config: Config)
    local self = setmetatable(prototype({} :: any, config), module.metatable)

    return self :: Type
end

---->> Private Functions

local function FindSpawnLeafParts(folder: Instance): {BasePart}
    local spawnLeafParts = {}

    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") and child.Name == "Spawn_Leaf" then
            table.insert(spawnLeafParts, child)
        elseif child:IsA("Folder") or child:IsA("Model") then
            local childParts = FindSpawnLeafParts(child)
            for _, part in ipairs(childParts) do
                table.insert(spawnLeafParts, part)
            end
        end
    end

    return spawnLeafParts
end

local function ProcessSpawnLeafParts(spawnLeafParts: {BasePart})
    for _, part in ipairs(spawnLeafParts) do
        local tags = CollectionService:GetTags(part)

        for _, tag in ipairs(tags) do
            local areaData = LeafArea.Get(tag)
            if areaData then
                part:SetAttribute("Limited", areaData.Limited)
                part:SetAttribute("Cooldown", areaData.Cooldown)
                break 
            end
        end
    end
end

---->> APIs
function module.methods.Initialize(self: Type, leafSystem: any)
    local spawnLeafParts = FindSpawnLeafParts(mapFolder)
    ProcessSpawnLeafParts(spawnLeafParts)

    -- Start spawning for all areas
    if leafSystem then
        for _, part in ipairs(spawnLeafParts) do
            leafSystem:StartAreaSpawning(part)
        end
    end
end

function module.methods.ResetAreaLimits(self: Type)
    local spawnLeafParts = FindSpawnLeafParts(mapFolder)
    ProcessSpawnLeafParts(spawnLeafParts)
end

function module.methods.GetSpawnLeafParts(self: Type): {BasePart}
    return FindSpawnLeafParts(mapFolder)
end

function module.methods.Destroy(self: Type)
    local _p = self._private
    for _, data in ipairs(_p.tasks) do
        local task_ = data.Thread
        if coroutine.status(task_) == "suspended" then
            task.cancel(task_)
        else
            task.defer(function()
                task.cancel(task_)
            end)
        end
    end
    for _, data in ipairs(_p.connections) do
        local conn = data.Connection
        conn:Disconnect()
    end

    do --other destroy logic
    end

    table.clear(self :: any)
end

function module.methods.DoABC(self: Type)
    print("Super DoABC")
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
