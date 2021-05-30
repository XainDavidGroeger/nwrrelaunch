--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 108,["6"] = 108,["7"] = 109,["8"] = 110,["10"] = 108,["11"] = 114,["12"] = 115,["13"] = 116,["14"] = 117,["15"] = 118,["16"] = 119,["17"] = 119,["18"] = 119,["19"] = 119,["21"] = 122,["23"] = 114,["24"] = 126,["25"] = 127,["26"] = 128,["27"] = 129,["28"] = 132,["29"] = 133,["32"] = 137,["34"] = 126,["35"] = 2,["36"] = 2,["37"] = 2,["39"] = 2,["40"] = 5,["41"] = 5,["42"] = 5,["44"] = 5,["45"] = 8,["46"] = 8,["47"] = 8,["49"] = 8,["50"] = 9,["51"] = 16,["52"] = 9,["53"] = 21,["54"] = 21,["55"] = 21,["56"] = 21,["57"] = 24,["58"] = 24,["59"] = 24,["60"] = 24,["61"] = 27,["62"] = 27,["63"] = 27,["64"] = 27,["65"] = 30,["66"] = 31,["67"] = 32,["68"] = 34,["69"] = 35,["70"] = 37,["72"] = 39,["74"] = 42,["75"] = 42,["76"] = 42,["77"] = 44,["78"] = 45,["80"] = 47,["82"] = 50,["83"] = 52,["84"] = 53,["85"] = 54,["86"] = 55,["87"] = 56,["89"] = 53,["90"] = 34,["91"] = 61,["92"] = 62,["93"] = 64,["95"] = 66,["97"] = 69,["98"] = 69,["99"] = 69,["100"] = 70,["101"] = 72,["102"] = 73,["104"] = 75,["106"] = 78,["107"] = 80,["108"] = 81,["109"] = 82,["110"] = 83,["111"] = 84,["113"] = 81,["114"] = 88,["115"] = 89,["116"] = 90,["117"] = 91,["118"] = 92,["120"] = 94,["121"] = 95,["123"] = 97,["124"] = 98,["127"] = 102,["129"] = 105,["130"] = 61});
local ____exports = {}
local clearTable, getFileScope, toDotaClassInstance
function clearTable(self, ____table)
    for key in pairs(____table) do
        __TS__Delete(____table, key)
    end
end
function getFileScope(self)
    local level = 1
    while true do
        local info = debug.getinfo(level, "S")
        if info and (info.what == "main") then
            return {
                getfenv(level),
                info.source
            }
        end
        level = level + 1
    end
end
function toDotaClassInstance(self, instance, ____table)
    local prototype = ____table.prototype
    while prototype do
        for key in pairs(prototype) do
            if not (rawget(instance, key) ~= nil) then
                instance[key] = prototype[key]
            end
        end
        prototype = getmetatable(prototype)
    end
end
____exports.BaseAbility = __TS__Class()
local BaseAbility = ____exports.BaseAbility
BaseAbility.name = "BaseAbility"
function BaseAbility.prototype.____constructor(self)
end
____exports.BaseItem = __TS__Class()
local BaseItem = ____exports.BaseItem
BaseItem.name = "BaseItem"
function BaseItem.prototype.____constructor(self)
end
____exports.BaseModifier = __TS__Class()
local BaseModifier = ____exports.BaseModifier
BaseModifier.name = "BaseModifier"
function BaseModifier.prototype.____constructor(self)
end
function BaseModifier.apply(self, target, caster, ability, modifierTable)
    return target:AddNewModifier(caster, ability, self.name, modifierTable)
end
____exports.BaseModifierMotionHorizontal = __TS__Class()
local BaseModifierMotionHorizontal = ____exports.BaseModifierMotionHorizontal
BaseModifierMotionHorizontal.name = "BaseModifierMotionHorizontal"
__TS__ClassExtends(BaseModifierMotionHorizontal, ____exports.BaseModifier)
____exports.BaseModifierMotionVertical = __TS__Class()
local BaseModifierMotionVertical = ____exports.BaseModifierMotionVertical
BaseModifierMotionVertical.name = "BaseModifierMotionVertical"
__TS__ClassExtends(BaseModifierMotionVertical, ____exports.BaseModifier)
____exports.BaseModifierMotionBoth = __TS__Class()
local BaseModifierMotionBoth = ____exports.BaseModifierMotionBoth
BaseModifierMotionBoth.name = "BaseModifierMotionBoth"
__TS__ClassExtends(BaseModifierMotionBoth, ____exports.BaseModifier)
setmetatable(____exports.BaseAbility.prototype, {__index = CDOTA_Ability_Lua or C_DOTA_Ability_Lua})
setmetatable(____exports.BaseItem.prototype, {__index = CDOTA_Item_Lua or C_DOTA_Item_Lua})
setmetatable(____exports.BaseModifier.prototype, {__index = CDOTA_Modifier_Lua or C_DOTA_Modifier_Lua})
____exports.registerAbility = function(____, name) return function(____, ability)
    if name ~= nil then
        ability.name = name
    else
        name = ability.name
    end
    local env = unpack(
        getFileScope(nil)
    )
    if env[name] then
        clearTable(nil, env[name])
    else
        env[name] = {}
    end
    toDotaClassInstance(nil, env[name], ability)
    local originalSpawn = env[name].Spawn
    env[name].Spawn = function(self)
        self:____constructor()
        if originalSpawn then
            originalSpawn(self)
        end
    end
end end
____exports.registerModifier = function(____, name) return function(____, modifier)
    if name ~= nil then
        modifier.name = name
    else
        name = modifier.name
    end
    local env, source = unpack(
        getFileScope(nil)
    )
    local fileName = string.gsub(source, ".*scripts[\\/]vscripts[\\/]", "")
    if env[name] then
        clearTable(nil, env[name])
    else
        env[name] = {}
    end
    toDotaClassInstance(nil, env[name], modifier)
    local originalOnCreated = env[name].OnCreated
    env[name].OnCreated = function(self, parameters)
        self:____constructor()
        if originalOnCreated then
            originalOnCreated(self, parameters)
        end
    end
    local ____type = LUA_MODIFIER_MOTION_NONE
    local base = modifier.____super
    while base do
        if base == ____exports.BaseModifierMotionBoth then
            ____type = LUA_MODIFIER_MOTION_BOTH
            break
        elseif base == ____exports.BaseModifierMotionHorizontal then
            ____type = LUA_MODIFIER_MOTION_HORIZONTAL
            break
        elseif base == ____exports.BaseModifierMotionVertical then
            ____type = LUA_MODIFIER_MOTION_VERTICAL
            break
        end
        base = base.____super
    end
    LinkLuaModifier(name, fileName, ____type)
end end
return ____exports
