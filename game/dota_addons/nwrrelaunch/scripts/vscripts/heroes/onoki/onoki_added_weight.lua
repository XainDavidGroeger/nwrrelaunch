onoki_added_weight = class({})
LinkLuaModifier( "modifier_onoki_added_weight_allies", "heroes/onoki/modifier_onoki_added_weight_allies", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_onoki_added_weight_enemy", "heroes/onoki/modifier_onoki_added_weight_enemy", LUA_MODIFIER_MOTION_NONE )

function onoki_added_weight:Precache( context )
	PrecacheResource( "soundfile", "soundevents/onoki_speedbuff_cast.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/onoki_debuff_cast.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_turn_to_stone.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_speed_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_speed_buff_status2.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_speed_buff.vpcf", context )
end

function onoki_added_weight:GetBehavior()
    return self.BaseClass.GetBehavior(self)
end

-- function onoki_added_weight:CastFilterResultTarget(hTarget)
--     return UF_SUCCESS
-- end

function onoki_added_weight:GetCooldown(iLevel)
	local abilityScd = self:GetCaster():FindAbilityByName("special_bonus_onoki_2")
	local cdredusction = self.BaseClass.GetCooldown(self, iLevel) / 100 * 14
	if abilityScd:GetLevel() > 0 then
		return self.BaseClass.GetCooldown(self, iLevel) - cdredusction
	else
	    return self.BaseClass.GetCooldown(self, iLevel)
	end
end

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
		
		local sound_cast = "onoki_speedbuff_cast"
	    EmitSoundOn(sound_cast, target)
    else
		target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_onoki_added_weight_enemy", -- modifier name
            { duration = duration } -- kv
        )
		
		local sound_cast = "onoki_debuff_cast"
	    EmitSoundOn(sound_cast, target)
    end

end