--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
-->> Reference
local Map1 = workspace:WaitForChild("Map1")
local Leaf = ReplicatedStorage.Leaf
-->> Constants
local CHUNK_SIZE = 32
--
export type APIsType = {
    chunks : {},
    leafToKey : {}
}

local module = {
    chunks = {},
    leafToKey = {},
} :: APIsType & Yumi.System

local function ChunkOf(pos: Vector3)
    local cx = math.floor(pos.X/CHUNK_SIZE)
    local cy = math.floor(pos.Y/CHUNK_SIZE)

    return cx, cy
end

local function ChunkKey(cx,cy): string
    return tostring(cx) .. "," .. tostring(cy)
end

local function addLeafToChunk(leaf: Model)
    print("leaf",leaf)
    local prm = leaf:FindFirstChild("Part") 
    print("prm",prm)
	local cx, cz = ChunkOf(prm.Position)
    print("cx,cz", cx,cz)
	local k = ChunkKey(cx, cz)
    print("k",k)
	module.chunks[k] = module.chunks[k] or {}
	module.chunks[k][leaf] = true
	module.leafToKey[leaf] = k
end

-- local function spawnLeafAt(pos: Vector3, leafTemplate: BasePart, parent: Instance)
-- 	local leaf = leafTemplate:Clone() :: 
-- 	leaf.Position = pos
-- 	leaf.Parent = parent

-- 	-- để query được
-- 	leaf.CanQuery = true
-- 	leaf.Transparency = 0

-- 	addLeafToChunk(leaf)
-- 	return leaf
-- end

local function getRandomPointInPart(model: Model): Vector3
    local part = model:FindFirstChild("Part") :: BasePart
    local size = part.Size
    local cf = part.CFrame

    local offset = Vector3.new(
        (math.random() - 0.5) * size.X,
        size.y + 2,
        (math.random() - 0.5) * size.Z
    )
    return (cf * CFrame.new(offset)).Position
end



-- local function removeLeafFromChunk(leaf: BasePart)
-- 	local k = leafToKey[leaf]
-- 	if not k then return end

-- 	local bucket = chunks[k]
-- 	if bucket then
-- 		bucket[leaf] = nil
-- 		-- nếu bucket rỗng bạn có thể dọn luôn:
-- 		-- if next(bucket) == nil then chunks[k] = nil end
-- 	end

-- 	leafToKey[leaf] = nil
-- end

--// Yumi

--// APIs
module._Start = function()
    local obj = Leaf:Clone() :: Model
    local prm  = obj.PrimaryPart
    if prm then 
        prm.Position = getRandomPointInPart(Map1)
        obj.Parent = workspace
    end
    addLeafToChunk(obj)

    -- obj.Position = getRandomPointInPart(Map1)
    -- obj.Parent = workspace
end

return module
