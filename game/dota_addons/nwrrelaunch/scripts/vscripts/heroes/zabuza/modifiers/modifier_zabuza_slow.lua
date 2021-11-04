modifier_zabuza_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_zabuza_slow:IsHidden()
	return false
end

function modifier_zabuza_slow:IsDebuff()
	return true
end

function modifier_zabuza_slow:IsStunDebuff()
	return false
end

function modifier_zabuza_slow:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_zabuza_slow:OnCreated( kv )
	-- references
	self.caster = self:GetCaster()
	self.slow_percent = self:GetAbility():GetSpecialValueFor( "ms_slow_start" )
end

function modifier_zabuza_slow:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_zabuza_slow:OnRemoved()
end

function modifier_zabuza_slow:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_zabuza_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE  ,
	}

	return funcs
end

function modifier_zabuza_slow:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self.slow_percent
end


--------------------------------------------------------------------------------
-- Status Effects
function modifier_zabuza_slow:CheckState()
	local state = {	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
--[[function modifier_zabuza_slow:GetStatusEffectName()
    return "particles/units/heroes/onoki/onoki_turn_to_stone.vpcf"
end

--------------------------------------------------------------------------------

function modifier_zabuza_slow:StatusEffectPriority()
    return 1000
end

--------------------------------------------------------------------------------

function modifier_zabuza_slow:GetEffectName()
    return "particles/units/heroes/onoki/onoki_speed_debuff.vpcf"
end

function modifier_zabuza_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end]]
