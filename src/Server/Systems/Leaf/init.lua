--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Constant && Module
local CONSTANT = require(ReplicatedStorage.Shared.CONSTANT)
local NormalTree = require(ReplicatedStorage.Shared.Libraries.Leaf.Tree.NormalTree)

-- Refs Test
local Leaf =  ReplicatedStorage.Assets.Leaf.Leaf

----> Constructor
export type Config = {
	Part1: BasePart,
}
local function prototype(self, config: Config)
	---->> Public
	self.Part1 = config.Part1

	---->> Private
	type field = {
		tasks: { { Name: string, Thread: thread } },
		connections: { { Name: string, Connection: RBXScriptConnection } },
		activeLeaves: { Instance },
		pooledLeaves: { Instance },
		lastSpawnTime: number,
		spawnCount: number,
		leafData: { [string]: any },
	}
	local _private = {
		tasks = {},
		connections = {},
		activeLeaves = {},
		pooledLeaves = {},
		lastSpawnTime = 0,
		spawnCount = 0,
		leafData = {},
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

---->> APIs
function module.methods.Initialize(self: Type)
	local _p = self._private
	_p.leafData = {
		Normal_Leaf_Common = NormalTree.Get(NormalTree.Id.Normal_Leaf_Common),
		Normal_Leaf_Uncommon = NormalTree.Get(NormalTree.Id.Normal_Leaf_Uncommon),
		Normal_Leaf_Rare = NormalTree.Get(NormalTree.Id.Normal_Leaf_Rare),
		Normal_Leaf_Epic = NormalTree.Get(NormalTree.Id.Normal_Leaf_Epic),
		Normal_Leaf_Legend = NormalTree.Get(NormalTree.Id.Normal_Leaf_Legend),
	}
end

function module.methods.CreateLeaf(self: Type): Instance
	local _p = self._private
	local cloneLeaf = Leaf:Clone()

	cloneLeaf:AddTag(CONSTANT.TAG.LEAF)

	cloneLeaf.Parent = workspace.Map.Map1

	return cloneLeaf
end

function module.methods.GetPooledLeaf(self: Type): Instance?
	local _p = self._private

	if #_p.pooledLeaves == 0 then
		return self:CreateLeaf()
	end

	local leaf = table.remove(_p.pooledLeaves)
	if leaf then
		leaf.Parent = workspace
		if (leaf :: any):IsA("BasePart") then
			(leaf :: BasePart).Anchored = false
		elseif (leaf :: any):IsA("Model") then
			local primaryPart = (leaf :: Model).PrimaryPart
			if primaryPart then
				primaryPart.Anchored = false
			end
		end
	end

	return leaf
end

function module.methods.ReturnLeafToPool(self: Type, leaf: Instance)
	local _p = self._private

	for i, activeLeaf in ipairs(_p.activeLeaves) do
		if activeLeaf == leaf then
			table.remove(_p.activeLeaves, i)
			break
		end
	end

	if (leaf :: any):IsA("BasePart") then
		(leaf :: BasePart).Anchored = true
		(leaf :: BasePart).Position = Vector3.new(0, -1000, 0)
	elseif (leaf :: any):IsA("Model") then
		local primaryPart = (leaf :: Model).PrimaryPart
		if primaryPart then
			primaryPart.Anchored = true
			primaryPart.Position = Vector3.new(0, -1000, 0)
		end
	end
	leaf.Parent = nil

	table.insert(_p.pooledLeaves, leaf)
end

function module.methods.CanSpawnLeaf(self: Type): boolean
	local _p = self._private
	local currentTime = os.clock()

	if _p.spawnCount >= CONSTANT.Spawn_Behavior.Spawn_Limit then
		return false
	end

	if currentTime - _p.lastSpawnTime < CONSTANT.Spawn_Behavior.Cooldown then
		return false
	end

	return true
end

function module.methods.SpawnLeaf(self: Type): Instance?
	local _p = self._private

	if not self:CanSpawnLeaf() then
		return nil
	end

	local selectedLeafType = self:SelectLeafByRate()
	if not selectedLeafType then
		return nil
	end

	local leaf = self:GetPooledLeaf()
	if not leaf then
		return nil
	end

	local spawnPosition = (self.Part1 :: BasePart).Position + Vector3.new(math.random(-5, 5), 5, math.random(-5, 5))
	if (leaf :: any):IsA("BasePart") then
		(leaf :: BasePart).Position = spawnPosition
	elseif (leaf :: any):IsA("Model") then
		local primaryPart = (leaf :: Model).PrimaryPart
		if primaryPart then
			primaryPart.Position = spawnPosition
		end
	end

	table.insert(_p.activeLeaves, leaf)

	_p.lastSpawnTime = os.clock()
	_p.spawnCount += 1

	task.delay(10, function()
		if leaf and leaf.Parent then
			self:ReturnLeafToPool(leaf)
		end
	end)

	return leaf
end

function module.methods.SelectLeafByRate(self: Type): string?
	local _p = self._private
	local randomValue = math.random()

	for leafId, leafInfo in pairs(_p.leafData) do
		if randomValue <= leafInfo.Rate then
			return leafId
		end
		randomValue = randomValue - leafInfo.Rate
	end

	return nil
end

function module.methods.GetActiveLeafCount(self: Type): number
	return #self._private.activeLeaves
end

function module.methods.GetSpawnCount(self: Type): number
	return self._private.spawnCount
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
		for _, leaf in ipairs(_p.activeLeaves) do
			if leaf and leaf.Parent then
				leaf:Destroy()
			end
		end
		for _, leaf in ipairs(_p.pooledLeaves) do
			if leaf then
				leaf:Destroy()
			end
		end
	end

	table.clear(self :: any)
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
