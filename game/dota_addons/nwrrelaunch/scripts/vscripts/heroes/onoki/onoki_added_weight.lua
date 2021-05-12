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
	if abilityScd ~= nil then
	    if abilityScd:GetLevel() > 0 then
	    	return self.BaseClass.GetCooldown(self, iLevel) - cdredusction
	    else
	        return self.BaseClass.GetCooldown(self, iLevel)
	    end
	end
end

function onoki_added_weight:CanBeReflected(bool, target)
	if bool == true then
        if target:TriggerSpellReflect(self) then return end
	else
	    --[[ simulate the cancellation of the ability if it is not reflected ]]
	    ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
		EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
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
	    --[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
        if target:FindModifierByName("modifier_item_lotus_orb_active") then
            self:CanBeReflected(true, target)
	    	
            return
        end
	    
	    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
	    if target:TriggerSpellAbsorb(self) then return end
		
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