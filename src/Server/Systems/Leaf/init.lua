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
local CONSTANT = require(game.ReplicatedStorage.Shared.CONSTANT)

local leafFolder = ReplicatedStorage.Assets.Leaf

local function LeafTemplate()
    return function(leafType: string)
        local leafData = Leaf.Data[leafType]
        if not leafData then
            warn(`Leaf type {leafType} not found in data`)
            return nil
        end

        local areaTag = leafData.Area

        for _, model in ipairs(leafFolder:GetChildren()) do
            if model:IsA("Model") then
                local modelTags = CollectionService:GetTags(model)
                for _, tag in ipairs(modelTags) do
                    if tag == areaTag then
                        local clonedModel = model:Clone()
                        return clonedModel
                    end
                end
            end
        end

        warn(`No leaf model found for area tag: {areaTag}`)
        return nil
    end
end

----> Constructor
export type Config = {
    PoolSize: number?,
}
local function prototype(self, config: Config)
    ---->> Public
    self.LeafTemplate = LeafTemplate()

    ---->> Private
    type field = {
        tasks: { {Name: string, Thread: thread} },
        connections: { {Name: string, Connection: RBXScriptConnection} },
        activeSpawnTasks: { [BasePart]: thread },
        areaLimits: { [BasePart]: number },
    }
    local _private = {
        tasks = {},
        connections = {},
        activeSpawnTasks = {},
        areaLimits = {},
    } :: field
    self._private = _private

    return self
end

---->> Public Properties
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {}
function module.constructors.new(config: Config?)
    config = config or {}
    local self = setmetatable(prototype({} :: any, config :: Config), module.metatable)

    return self :: Type
end

---->> Private Functions

local function GetRandomLeafType(areaTag: string): string?
    local leafData = {}

    for leafId, leafInfo in pairs(Leaf.Data) do
        if leafInfo.Area == areaTag then
            table.insert(leafData, {id = leafId, rate = leafInfo.Rate :: number})
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

    return leafData[1].id 
end

local function GetRandomPositionInArea(areaPart: BasePart): Vector3
    local size = areaPart.Size
    local cframe = areaPart.CFrame

    local randomX = math.random(-size.X/2, size.X/2)
    local randomZ = math.random(-size.Z/2, size.Z/2)
    local y = size.Y/2 + 1 

    return cframe.Position + cframe.RightVector * randomX + cframe.UpVector * y + cframe.LookVector * randomZ
end

local function CanSpawnInArea(areaPart: BasePart): boolean
    local currentLimit = areaPart:GetAttribute("Limited") or 0
    return (currentLimit :: number) > 0
end

local function DecrementAreaLimit(areaPart: BasePart): boolean
    local currentLimit = areaPart:GetAttribute("Limited") or 0
    if (currentLimit :: number) > 0 then
        areaPart:SetAttribute("Limited", (currentLimit :: number) - 1)
        return true
    end
    return false
end

---->> APIs
function module.methods.Initialize(self: Type) end

function module.methods.SpawnLeaf(self: Type, areaPart: BasePart): boolean
    local _p = self._private

    local tags = CollectionService:GetTags(areaPart)
    local areaTag: string?

    for _, tag in ipairs(tags) do
        if LeafArea.Get(tag) then
            areaTag = tag
            break
        end
    end

    if not areaTag then
        return false
    end

    local leafType = GetRandomLeafType(areaTag)
    if not leafType then
        return false
    end

    if not DecrementAreaLimit(areaPart) then
        return false
    end

    local leafInstance = self.LeafTemplate(leafType)
    if not leafInstance then
        return false
    end
    leafInstance.CFrame = CFrame.new(GetRandomPositionInArea(areaPart))
    leafInstance.Parent = workspace

    leafInstance:SetAttribute("LeafType", leafType)

    CollectionService:AddTag(leafInstance, CONSTANT.TAG.LEAF.LEAF)

    task.delay(30, function() 
        if leafInstance.Parent then
            leafInstance:Destroy()
        end
    end)

    return true
end

function module.methods.StartAreaSpawning(self: Type, areaPart: BasePart)
    local _p = self._private

    if _p.activeSpawnTasks[areaPart] then
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
        return
    end

    _p.activeSpawnTasks[areaPart] = task.spawn(function()
        while true do
            if not CanSpawnInArea(areaPart) then
                break
            end

            self:SpawnLeaf(areaPart)

            task.wait(areaData.Cooldown)
        end

        _p.activeSpawnTasks[areaPart] = nil
    end)
end

function module.methods.StopAreaSpawning(self: Type, areaPart: BasePart)
    local _p = self._private

    local taskThread = _p.activeSpawnTasks[areaPart]
    if taskThread then
        task.cancel(taskThread)
        _p.activeSpawnTasks[areaPart] = nil
    end
end

function module.methods.StartAllAreaSpawning(self: Type, areaSystem: any)
    local spawnLeafParts = areaSystem:GetSpawnLeafParts()
    for _, part in ipairs(spawnLeafParts) do
        self:StartAreaSpawning(part)
    end
end

function module.methods.Destroy(self: Type)
    local _p = self._private

    for areaPart, taskThread in pairs(_p.activeSpawnTasks) do
        task.cancel(taskThread)
    end
    table.clear(_p.activeSpawnTasks)

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

    table.clear(self :: any)
end
function module.methods.DoABC(self: Type)
    print("Super DoABC")
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
