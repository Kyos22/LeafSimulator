--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services

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

---->> APIs
function module.methods.Initialize(self: Type) end

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
