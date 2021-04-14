onoki_added_weight = class({})
LinkLuaModifier( "modifier_onoki_added_weight_allies", "heroes/onoki/modifier_onoki_added_weight_allies", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_onoki_added_weight_enemy", "heroes/onoki/modifier_onoki_added_weight_enemy", LUA_MODIFIER_MOTION_NONE )

function onoki_added_weight:Precache( context )
	-- PrecacheResource( "soundfile", "xx.vsndevts", context )
	-- PrecacheResource( "particle", "xx.vpcf", context )
end

-- function onoki_added_weight:GetBehavior()
--     return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
-- end

-- function onoki_added_weight:CastFilterResultTarget(hTarget)
--     return UF_SUCCESS
-- end

--Starta
function onoki_added_weight:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

    if target:GetTeamNumber() == caster:GetTeamNumber() then
        target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_onoki_added_weight_allies", -- modifier name
            { duration = duration } -- kv
        )
    else
        target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_onoki_added_weight_enemy", -- modifier name
            { duration = duration } -- kv
        )
    end

end