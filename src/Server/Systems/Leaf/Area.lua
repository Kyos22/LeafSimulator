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
local function prototype(self, config: any)
    ---->> Private fields definition
    type field = {
        tasks: { {Name: string, Thread: thread} },
        connections: { {Name: string, Connection: RBXScriptConnection} },
        spawnLeafParts: {BasePart}?,
    }

    -- Private data table (encapsulated state)
    local _private = {
        tasks = {},
        connections = {},
        spawnLeafParts = nil,           -- cache for Spawn_Leaf parts
    } :: field

    self._private = _private

    return self
end

---->> Public Properties / Constructor helpers
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {}

--- Creates a new instance of the Leaf Spawn Manager
function module.constructors.new(config: any?)
    local self = setmetatable(prototype({} :: any, config or {}), module.metatable)
    return self :: Type
end

---->> Private Helper Functions

-- Recursively finds all parts named "Spawn_Leaf" inside a folder/model
local function FindAllSpawnLeafParts(root: Instance): {BasePart}
    local spawnLeafParts = {}

    local function recurse(instance: Instance)
        for _, child in instance:GetChildren() do
            if child:IsA("BasePart") and child.Name == "Spawn_Leaf" then
                table.insert(spawnLeafParts, child)
            elseif child:IsA("Folder") or child:IsA("Model") then
                recurse(child)
            end
        end
    end

    recurse(root)
    return spawnLeafParts
end

-- Finds and caches all "Spawn_Leaf" parts in the entire Map
local function FindSpawnLeafParts(self): {BasePart}
    local _p = self._private
    
    if _p.spawnLeafParts then
        return _p.spawnLeafParts
    end

    local spawnLeafParts = FindAllSpawnLeafParts(mapFolder)
    
    _p.spawnLeafParts = spawnLeafParts
    return spawnLeafParts
end

-- Applies LeafArea attributes (Limited, Cooldown) to all Spawn_Leaf parts
local function ProcessSpawnLeafParts(spawnLeafParts: {BasePart})
    for _, part in ipairs(spawnLeafParts) do
        local tags = CollectionService:GetTags(part)
        
        for _, tag in ipairs(tags) do
            local areaData = LeafArea.Get(tag)
            if areaData then
                part:SetAttribute("Limited", areaData.Limited)
                part:SetAttribute("Cooldown", areaData.Cooldown)
                break   -- assume one matching area tag per part
            end
        end
    end
end

---->> Public Methods

-- Initializes the system: finds parts + applies attributes + starts spawning if leafSystem provided
function module.methods.Initialize(self: Type, leafSystem: any)
    local spawnLeafParts = FindSpawnLeafParts(self)
    ProcessSpawnLeafParts(spawnLeafParts)

    if leafSystem then
        for _, part in ipairs(spawnLeafParts) do
            leafSystem:StartAreaSpawning(part)
        end
    end
end

-- Re-applies area attributes to all Spawn_Leaf parts (useful after map changes or resets)
function module.methods.ResetAreaLimits(self: Type)
    local spawnLeafParts = FindSpawnLeafParts(self)
    ProcessSpawnLeafParts(spawnLeafParts)
end

-- Returns the list of all cached Spawn_Leaf parts
function module.methods.GetSpawnLeafParts(self: Type): {BasePart}
    return FindSpawnLeafParts(self)
end

-- Clears the cache of Spawn_Leaf parts (forces re-scan on next use)
function module.methods.ClearSpawnLeafCache(self: Type)
    self._private.spawnLeafParts = nil
end

-- Cleans up the instance: cancels tasks, disconnects connections, clears data
function module.methods.Destroy(self: Type)
    local _p = self._private

    -- Cancel all running tasks/coroutines safely
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

    -- Disconnect all connections
    for _, data in ipairs(_p.connections) do
        local conn = data.Connection
        conn:Disconnect()
    end

    -- Add any additional cleanup logic here if needed
    do --other destroy logic
    end

    -- Clear the object (optional but good practice)
    table.clear(self :: any)
end

-- Example / placeholder method
function module.methods.DoABC(self: Type)
    print("Super DoABC")
end

-- Type definition for Luau type checking
export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors