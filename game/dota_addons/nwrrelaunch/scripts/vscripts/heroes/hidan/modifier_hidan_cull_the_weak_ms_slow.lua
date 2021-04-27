modifier_hidan_cull_the_weak_ms_slow = class({})

-- Classifications
function modifier_hidan_cull_the_weak_ms_slow:IsHidden()
	return false
end

function modifier_hidan_cull_the_weak_ms_slow:IsDebuff()
	return true
end

function modifier_hidan_cull_the_weak_ms_slow:IsStunDebuff()
	return false
end

function modifier_hidan_cull_the_weak_ms_slow:IsPurgable()
	return true
end

-- Initializations
function modifier_hidan_cull_the_weak_ms_slow:OnCreated( kv )
	-- references
	self.slow = -self:GetAbility():GetSpecialValueFor( "ms_slow_percentage" )
end

function modifier_hidan_cull_the_weak_ms_slow:OnRefresh( kv )
	-- references
	self.slow = -self:GetAbility():GetSpecialValueFor( "ms_slow_percentage" )	
end

function modifier_hidan_cull_the_weak_ms_slow:OnRemoved()
end

function modifier_hidan_cull_the_weak_ms_slow:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_hidan_cull_the_weak_ms_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_hidan_cull_the_weak_ms_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_hidan_cull_the_weak_ms_slow:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_debuff.vpcf"
end

function modifier_hidan_cull_the_weak_ms_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_hidan_cull_the_weak_ms_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_slow.vpcf"
end

function modifier_hidan_cull_the_weak_ms_slow:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end