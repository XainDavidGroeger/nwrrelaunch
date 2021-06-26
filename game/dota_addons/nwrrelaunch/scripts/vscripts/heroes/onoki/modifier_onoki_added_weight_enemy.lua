modifier_onoki_added_weight_enemy = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_onoki_added_weight_enemy:IsHidden()
	return false
end

function modifier_onoki_added_weight_enemy:IsDebuff()
	return true
end

function modifier_onoki_added_weight_enemy:IsStunDebuff()
	return false
end

function modifier_onoki_added_weight_enemy:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_onoki_added_weight_enemy:OnCreated( kv )
	-- references
	self.caster = self:GetCaster()
	local abilityS = self.caster:FindAbilityByName("special_bonus_onoki_4")
	self.speed_penalty_perc = self:GetAbility():GetSpecialValueFor( "speed_penalty_perc" )
	
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
        	self.speed_penalty_perc = self.speed_penalty_perc + 7
	    end
	end

	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manaloss_modifier" )

end

function modifier_onoki_added_weight_enemy:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_onoki_added_weight_enemy:OnRemoved()
end

function modifier_onoki_added_weight_enemy:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_onoki_added_weight_enemy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}

	return funcs
end

function modifier_onoki_added_weight_enemy:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self.speed_penalty_perc
end

function modifier_onoki_added_weight_enemy:GetModifierPercentageManacostStacking()
	return -1 * self.manacost_reduction
end


--------------------------------------------------------------------------------
-- Status Effects
function modifier_onoki_added_weight_enemy:CheckState()
	local state = {	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_onoki_added_weight_enemy:GetStatusEffectName()
    return "particles/units/heroes/onoki/onoki_turn_to_stone.vpcf"
end

--------------------------------------------------------------------------------

function modifier_onoki_added_weight_enemy:StatusEffectPriority()
    return 1000
end

--------------------------------------------------------------------------------

function modifier_onoki_added_weight_enemy:GetEffectName()
    return "particles/units/heroes/onoki/onoki_speed_debuff.vpcf"
end

function modifier_onoki_added_weight_enemy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
