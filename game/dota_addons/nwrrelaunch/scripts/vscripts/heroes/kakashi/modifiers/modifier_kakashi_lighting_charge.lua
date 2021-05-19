modifier_kakashi_lighting_charge = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_kakashi_lighting_charge:IsHidden()
	return false
end

function modifier_kakashi_lighting_charge:IsDebuff()
	return true
end

function modifier_kakashi_lighting_charge:IsStunDebuff()
	return false
end

function modifier_kakashi_lighting_charge:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_kakashi_lighting_charge:OnCreated( kv )
	-- references
	self.caster = self:GetCaster()
	self.slow_percent = self:GetAbility():GetSpecialValueFor("ms_debuff")
end

function modifier_kakashi_lighting_charge:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_kakashi_lighting_charge:OnRemoved()
end

function modifier_kakashi_lighting_charge:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_kakashi_lighting_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE  ,
	}

	return funcs
end

function modifier_kakashi_lighting_charge:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_percent
end


--------------------------------------------------------------------------------
-- Status Effects
function modifier_kakashi_lighting_charge:CheckState()
	local state = {	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
--[[function modifier_kakashi_lighting_charge:GetStatusEffectName()
    return "particles/units/heroes/onoki/onoki_turn_to_stone.vpcf"
end

--------------------------------------------------------------------------------

function modifier_kakashi_lighting_charge:StatusEffectPriority()
    return 1000
end]]

--------------------------------------------------------------------------------

function modifier_kakashi_lighting_charge:GetEffectName()
    return "particles/units/heroes/hero_razor/razor_ambient_g.vpcf"
end

function modifier_kakashi_lighting_charge:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
