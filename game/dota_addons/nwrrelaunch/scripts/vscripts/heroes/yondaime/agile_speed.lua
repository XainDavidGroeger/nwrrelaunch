yondaime_agile_speed = class({})

LinkLuaModifier("modifier_yondaime_agile_speed_passive", "heroes/yondaime/agile_speed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yondaime_agile_speed_active", "heroes/yondaime/agile_speed", LUA_MODIFIER_MOTION_NONE)

function yondaime_agile_speed:GetIntrinsicModifierName()
	return "modifier_yondaime_agile_speed_passive"
end

function yondaime_agile_speed:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_yondaime_agile_speed_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_yondaime_agile_speed_passive = class({})

function modifier_yondaime_agile_speed_passive:IsHidden() return false end
function modifier_yondaime_agile_speed_passive:IsDebuff() return false end
function modifier_yondaime_agile_speed_passive:IsPurgable() return true end


function modifier_yondaime_agile_speed_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_yondaime_agile_speed_passive:GetModifierPreAttack_BonusDamage()

	local bonus_damage_ms_perc = 0

	if self:GetParent():HasModifier("modifier_yondaime_agile_speed_active") then
		 bonus_damage_ms_perc = self:GetAbility():GetSpecialValueFor("bonus_damage_ms_percent_active")
	else
		 bonus_damage_ms_perc = self:GetAbility():GetSpecialValueFor("bonus_damage_ms_percent")
	end

	local movement_speed = self:GetParent():GetIdealSpeed()
	local bonus_damage = movement_speed / 100 * bonus_damage_ms_perc

	self:SetStackCount(bonus_damage)

	return bonus_damage
end

function modifier_yondaime_agile_speed_passive:GetModifierMoveSpeedBonus_Percentage()
	local bonus_movespeed_perc = 0
	if self:GetParent():HasModifier("modifier_yondaime_agile_speed_active") then
		bonus_movespeed_perc = self:GetAbility():GetSpecialValueFor("bonus_ms_percentage_active")
	else
		bonus_movespeed_perc = self:GetAbility():GetSpecialValueFor("bonus_ms_percentage")
	end

	return bonus_movespeed_perc
end

function modifier_yondaime_agile_speed_passive:OnCreated()
	local ability = self:GetAbility()
	self:GetAbility().modifier = self
end

modifier_yondaime_agile_speed_active = class({})

function modifier_yondaime_agile_speed_active:IsHidden() return false end
function modifier_yondaime_agile_speed_active:IsDebuff() return false end
function modifier_yondaime_agile_speed_active:IsPurgable() return true end

function modifier_yondaime_agile_speed_active:OnCreated()
	if not IsServer() then return end
	self:GetCaster():EmitSound("minato_flash_cast")
end


function modifier_yondaime_agile_speed_active:OnRemoved() 
	if not IsServer() then return end
end

function modifier_yondaime_agile_speed_active:GetEffectName()
	return "particles/units/heroes/yondaime/minato_flash_active.vpcf"
end