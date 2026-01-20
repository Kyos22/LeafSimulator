--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local Server = require(ReplicatedStorage.Shared.Network.Server)
-->> Reference
local Map1 = workspace:WaitForChild("Map1")
local Leaf = ReplicatedStorage.Leaf
-->> Constants
local CHUNK_SIZE = 32
--
export type APIsType = {
    chunks : {},
    leafToKey : {},
    DoSweep: (player:Player) -> (),
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

local function AddLeafToChunk(leaf: Model)
    local prm = leaf:FindFirstChild("Part") 
	local cx, cz = ChunkOf(prm.Position)
	local k = ChunkKey(cx, cz)
	module.chunks[k] = module.chunks[k] or {}
	module.chunks[k][leaf] = true
	module.leafToKey[leaf] = k
end


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
local function getCandidatesInRadius(center: Vector3, radius: number)
	local cx, cz = ChunkOf(center)
	local range = math.ceil(radius / CHUNK_SIZE) + 1

	local out = {}
	for dx = -range, range do
		for dz = -range, range do
			local bucket = module.chunks[ChunkKey(cx+dx, cz+dz)]
			if bucket then
				for leaf,_ in pairs(bucket) do
					out[#out+1] = leaf
				end
			end
		end
	end
	return out
end
-- 	leafToKey[leaf] = nil
-- end

--// Yumi
local MAX_LEAVES_PER_SWEEP = 20
--// APIs
module.DoSweep = function(player:Player)
    if not player then return end
    local character = player.Character or player.CharacterAdded:Wait()
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
    local center = humanoidRootPart and humanoidRootPart.Position
    local radius = 10
    local candidates = getCandidatesInRadius(center, radius)
    local r2 = radius * radius
    local swept = 0
    for _, leaf in ipairs(candidates) do
		-- check tồn tại + có thể query (lá chưa bị quét)
		if leaf and leaf.Parent and leaf.PrimaryPart then
			-- radius check (nhanh hơn distance vì dùng bình phương)
			local d = leaf.PrimaryPart.Position - center
           
			if (d.X*d.X  + d.Z*d.Z) <= r2 then
                print("dc")
				-- despawn / pooling
				-- leaf.CanQuery = false
				-- leaf.CanTouch = false
				-- leaf.CanCollide = false
				-- leaf.Transparency = 1
                leaf:Destroy()
				swept += 1
				if swept >= MAX_LEAVES_PER_SWEEP then
					break
				end
			end
		end
	end
end

module._Start = function()
    local obj = Leaf:Clone() :: Model
    local prm  = obj.PrimaryPart
    if prm then 
        prm.Position = getRandomPointInPart(Map1)
        obj.Parent = workspace
    end
    AddLeafToChunk(obj)

    -- obj.Position = getRandomPointInPart(Map1)
    -- obj.Parent = workspace

    Server.Tools.Click.On(function(player:Player)
        module.DoSweep(player)
    end)
end

return module

-- quét auto 
-- quét debounce dựa trên tools

