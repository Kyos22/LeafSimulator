--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--// Modules
local Leaf = require(game.ReplicatedStorage.Shared.Libraries.Leaf)
local LeafArea = require(game.ReplicatedStorage.Shared.Libraries.Leaf.LeafArea)

local leafFolder = ReplicatedStorage.Assets.Leaf

-- Helper function: Finds leaf data by leaf type from all categories
local function GetLeafData(leafType: string)
    for _, categoryData in pairs(Leaf.Data) do
        if categoryData[leafType] then
            return categoryData[leafType]
        end
    end
    return nil
end

-- Factory function that returns a function to create leaf models
local function LeafTemplate(self: any)
    return function(leafType: string)
        local leafData = GetLeafData(leafType)
        if not leafData then
            warn(`Leaf type {leafType} not found in data`)
            return nil
        end

        local areaTag = leafData.Area
        local cachedModel = self._private.cachedModels[areaTag]

        if cachedModel then
            return cachedModel:Clone()
        end

        warn(`No cached leaf model found for area tag: {areaTag}`)
        return nil
    end
end

----> Constructor
export type Config = {
    PoolSize: number?,
}

-- Initializes a new instance (prototype pattern)
local function prototype(self, config: Config)
    ---->> Public API
    self.LeafTemplate = LeafTemplate(self)

    ---->> Private data
    type field = {
        tasks: { {Name: string, Thread: thread} },
        connections: { {Name: string, Connection: RBXScriptConnection} },
        activeSpawnTasks: { [BasePart]: thread },
        areaLimits: { [BasePart]: number },
        cachedModels: { [string]: Model },
    }

    local _private = {
        tasks = {},
        connections = {},
        activeSpawnTasks = {},
        areaLimits = {},
        cachedModels = {},
    } :: field

    self._private = _private

    return self
end

---->> Public Properties / Constructor registry
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {}

-- Main constructor - creates and initializes a new LeafSystem instance
function module.constructors.new(config: Config?)
    config = config or {}

    local instance = {} :: any
    local self = setmetatable(prototype(instance, config :: Config), module.metatable)

    -- Cache all leaf models by their area tag
    for _, model in ipairs(leafFolder:GetChildren()) do
        if model:IsA("Model") then
            local modelTags = CollectionService:GetTags(model)
            for _, tag in ipairs(modelTags) do
                if not self._private.cachedModels[tag] then
                    self._private.cachedModels[tag] = model:Clone()
                end
            end
        end
    end

    return self :: Type
end

---->> Private Helper Functions

-- Selects a random leaf type for a given area tag using weighted random
local function GetRandomLeafType(areaTag: string): string?
    local leafData = {}
    for _, categoryData in pairs(Leaf.Data) do
        for leafId, leafInfo in pairs(categoryData) do
            if leafInfo.Area == areaTag then
                table.insert(leafData, {id = leafId, rate = leafInfo.Rate :: number})
            end
        end
    end

    if #leafData == 0 then
        return nil
    end

    local totalWeight = 0
    for _, data in ipairs(leafData) do
        totalWeight += data.rate
    end

    local random = math.random() * totalWeight
    local currentWeight = 0

    for _, data in ipairs(leafData) do
        currentWeight += data.rate
        if random <= currentWeight then
            return data.id
        end
    end

    return leafData[1].id  -- fallback
end

-- Generates a random position on the top surface of the area part
local function GetRandomPositionInArea(areaPart: BasePart): Vector3
    local size = areaPart.Size
    local cframe = areaPart.CFrame

    local randomX = (math.random() - 0.5) * size.X
    local randomZ = (math.random() - 0.5) * size.Z
    local surfaceY = size.Y / 2 + 0.5   -- slightly above surface

    return (cframe * CFrame.new(randomX, surfaceY, randomZ)).Position
end

-- Generates a random CFrame (position + random yaw rotation) on the area
local function GetRandomCFrameInArea(areaPart: BasePart): CFrame
    local position = GetRandomPositionInArea(areaPart)
    local randomYaw = math.random() * math.pi * 2
    return CFrame.new(position) * CFrame.Angles(0, randomYaw, 0)
end

-- Checks if spawning is still allowed in this area (based on Limited attribute)
local function CanSpawnInArea(areaPart: BasePart): boolean
    local currentLimit = areaPart:GetAttribute("Limited") or 0
    return (currentLimit :: number) > 0
end

-- Decrements the spawn limit counter for the area
local function DecrementAreaLimit(areaPart: BasePart): boolean
    local currentLimit = areaPart:GetAttribute("Limited") or 0
    if (currentLimit :: number) > 0 then
        areaPart:SetAttribute("Limited", (currentLimit :: number) - 1)
        return true
    end
    return false
end

-- Increments the spawn limit counter (called when a leaf is collected)
local function IncrementAreaLimit(areaPart: BasePart)
    local currentLimit = areaPart:GetAttribute("Limited") or 0
    areaPart:SetAttribute("Limited", (currentLimit :: number) + 1)
end

---->> Public Methods

function module.methods.Initialize(self: Type) 
    -- Currently empty - can be used for future initialization logic
end

-- Attempts to spawn one leaf in the specified area
function module.methods.SpawnLeaf(self: Type, areaPart: BasePart): boolean
    local _p = self._private

    -- Find the area tag
    local tags = CollectionService:GetTags(areaPart)
    local areaTag: string?
    for _, tag in ipairs(tags) do
        if LeafArea.Get(tag) then
            areaTag = tag
            break
        end
    end

    if not areaTag then
        warn(`[LeafSystem] No valid area tag found for part: {areaPart.Name}`)
        return false
    end

    local leafType = GetRandomLeafType(areaTag)
    if not leafType then
        warn(`[LeafSystem] No leaf type found for area tag: {areaTag}`)
        return false
    end

    -- Check and consume spawn limit
    if not DecrementAreaLimit(areaPart) then
        return false
    end

    local leafInstance = self.LeafTemplate(leafType)
    if not leafInstance then
        warn(`[LeafSystem] Failed to create leaf instance for type: {leafType}`)
        return false
    end

    -- Place the leaf randomly in the area
    leafInstance:PivotTo(GetRandomCFrameInArea(areaPart))
    leafInstance.Parent = areaPart
    leafInstance:SetAttribute("LeafType", leafType)

    if _G.LEAF_DEBUG then
        print(`[LeafSystem] Spawned {leafType} at area {areaTag}`)
    end

    return true
end

-- Called when a player collects a leaf
function module.methods.CollectLeaf(self: Type, leafInstance: Model)
    local _p = self._private

    local spawnArea = leafInstance.Parent
    if not spawnArea 
        or not spawnArea:IsA("BasePart") 
        or spawnArea.Name ~= "Spawn_Leaf" then
        
        warn(`[LeafSystem] Leaf instance is not in a valid spawn area: {leafInstance.Name}`)
        return false
    end

    IncrementAreaLimit(spawnArea)
    leafInstance:Destroy()

    if _G.LEAF_DEBUG then
        print(`[LeafSystem] Collected leaf and incremented limit for area: {spawnArea.Name}`)
    end

    return true
end

-- Starts a continuous spawning loop for the given area
function module.methods.StartAreaSpawning(self: Type, areaPart: BasePart)
    local _p = self._private

    if _p.activeSpawnTasks[areaPart] then
        warn(`[LeafSystem] Spawn task already active for area part: {areaPart.Name}`)
        return
    end

    local tags = CollectionService:GetTags(areaPart)
    local areaTag: string?
    local areaData
    for _, tag in ipairs(tags) do
        areaData = LeafArea.Get(tag)
        if areaData then
            areaTag = tag
            break
        end
    end

    if not areaTag or not areaData then
        warn(`[LeafSystem] No valid area data found for part: {areaPart.Name}`)
        return
    end

    _p.activeSpawnTasks[areaPart] = task.spawn(function()
        while true do
            if not areaPart:IsDescendantOf(workspace) then
                break
            end

            if not CanSpawnInArea(areaPart) then
                break
            end

            self:SpawnLeaf(areaPart)
            task.wait(areaData.Cooldown)
        end

        _p.activeSpawnTasks[areaPart] = nil
    end)
end

-- Stops the spawning loop for a specific area
function module.methods.StopAreaSpawning(self: Type, areaPart: BasePart)
    local _p = self._private
    local taskThread = _p.activeSpawnTasks[areaPart]

    if taskThread then
        task.cancel(taskThread)
        _p.activeSpawnTasks[areaPart] = nil
    end
end

-- Cleanup method - stops all tasks and disconnects connections
function module.methods.Destroy(self: Type)
    local _p = self._private

    -- Stop all spawning loops
    for areaPart, taskThread in pairs(_p.activeSpawnTasks) do
        task.cancel(taskThread)
    end
    table.clear(_p.activeSpawnTasks)

    -- Cancel other tasks (if any)
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

    table.clear(self :: any)
end

-- Debug / test method
function module.methods.DoABC(self: Type)
    print("Super DoABC")
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors