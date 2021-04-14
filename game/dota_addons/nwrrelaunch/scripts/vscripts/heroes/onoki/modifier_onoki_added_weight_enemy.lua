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
	self.speed_penalty_perc = self:GetAbility():GetSpecialValueFor( "speed_penalty_perc" )

	if not IsServer() then return end

	-- play effects
	local sound_cast = "Hero_Dark_Seer.Surge"
	EmitSoundOn( sound_cast, self:GetParent() )
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
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE  ,
	}

	return funcs
end

function modifier_onoki_added_weight_enemy:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self.speed_penalty_perc
end


--------------------------------------------------------------------------------
-- Status Effects
function modifier_onoki_added_weight_enemy:CheckState()
	local state = {	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_onoki_added_weight_enemy:GetEffectName()
	return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end

function modifier_onoki_added_weight_enemy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end