modifier_onoki_added_weight_allies = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_onoki_added_weight_allies:IsHidden()
	return false
end

function modifier_onoki_added_weight_allies:IsDebuff()
	return false
end

function modifier_onoki_added_weight_allies:IsStunDebuff()
	return false
end

function modifier_onoki_added_weight_allies:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_onoki_added_weight_allies:OnCreated( kv )
	-- references
	self.caster = self:GetCaster()
	local abilityS = self.caster:FindAbilityByName("special_bonus_onoki_4")
	self.speed_bonus_perc = self:GetAbility():GetSpecialValueFor( "speed_bonus_perc" )
	
	if abilityS ~= nil then
        if abilityS:GetLevel() > 0 then
        	self.speed_bonus_perc = self.speed_bonus_perc + 7
	    end
	end

	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manaloss_modifier" )
end

function modifier_onoki_added_weight_allies:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_onoki_added_weight_allies:OnRemoved()
end

function modifier_onoki_added_weight_allies:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_onoki_added_weight_allies:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
	}

	return funcs
end

function modifier_onoki_added_weight_allies:GetModifierMoveSpeedBonus_Percentage()
	return self.speed_bonus_perc
end

function modifier_onoki_added_weight_allies:GetModifierPercentageManacost()
	return self.manacost_reduction
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_onoki_added_weight_allies:CheckState()
	local state = {	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_onoki_added_weight_allies:GetStatusEffectName()
    return "particles/units/heroes/onoki/onoki_speed_buff_status2.vpcf"
end

--------------------------------------------------------------------------------

function modifier_onoki_added_weight_allies:StatusEffectPriority()
    return 1000
end

--------------------------------------------------------------------------------

function modifier_onoki_added_weight_allies:GetEffectName()
    return "particles/units/heroes/onoki/onoki_speed_buff.vpcf"
end

function modifier_onoki_added_weight_allies:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
