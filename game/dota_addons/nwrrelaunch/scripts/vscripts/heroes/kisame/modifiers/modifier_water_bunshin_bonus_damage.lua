modifier_water_bunshin_bonus_damage = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_water_bunshin_bonus_damage:IsHidden()
	return true
end

function modifier_water_bunshin_bonus_damage:IsDebuff()
	return false
end

function modifier_water_bunshin_bonus_damage:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_water_bunshin_bonus_damage:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_water_bunshin_bonus_damage:OnRefresh( kv )
self:OnCreated( kv )
end

function modifier_water_bunshin_bonus_damage:OnRemoved()
end

function modifier_water_bunshin_bonus_damage:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_water_bunshin_bonus_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

function modifier_water_bunshin_bonus_damage:GetModifierPreAttack_BonusDamage()
	return self.bonus
end