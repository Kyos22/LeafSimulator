local Tools = {}

export type ToolsType = {
    Name : string,
    Radius: number,
    Cooldown : number,
    MaxStrength : number,
}

local Data = {
    ["Basic Broom"] = {
        Name = "Basic Broom",
        Radius = 10,
        Cooldown = 1.2,
        MaxStrength = 1
    }, 
    ["Advance Broom"] = {
        Name = "Basic Broom",
        Radius = 10,
        Cooldown = 1.2,
        MaxStrength = 1
    }, 
} :: {[string]: ToolsType}


return Tools