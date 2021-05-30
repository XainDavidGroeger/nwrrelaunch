--[[
	Author: LearningDave
	Date: october, 12th 2015.
	Checks if the ms of the caster has changed and provies bonus damage based on the ms
]]
function apply_bonus_damage( data )
	if data.ability.ms == data.caster:GetIdealSpeed() then
		print('nothing should happend, cause ms didnt change')
	else 
		local caster = data.caster
		local ms = data.caster:GetIdealSpeed()
		local ms_bonus_percent_damage = data.ability:GetLevelSpecialValueFor("bonus_damage_ms_percent", data.ability:GetLevel() - 1 )
		local average_damage = caster:GetAverageTrueAttackDamage(caster)
		local agility_bonus = caster:GetAgility()
		local add_damage = ms / 100 * ms_bonus_percent_damage
		local modifierName = "modifier_agile_speed"
	
		data.ability:ApplyDataDrivenModifier( caster, caster, modifierName, { } )
		caster:SetModifierStackCount( modifierName, data.ability, add_damage )
	end 	
	
end
--[[
	Author: LearningDave
	Date: october, 12th 2015.
	Initiates the current ms for 'apply_bonus_damage'
]]
function init_agile_speed( data )
	data.ability.ms = data.caster:GetIdealSpeed()
end

yondaime_agile_speed = class({})

LinkLuaModifier("modifier_yondaime_agile_speed_passive", "heroes/yondaime/agile_speed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yondaime_agile_speed_active", "heroes/yondaime/agile_speed", LUA_MODIFIER_MOTION_NONE)

function yondaime_agile_speed:GetIntrinsicModifierName()
	return "modifier_yondaime_agile_speed_passive"
end

function yondaime_agile_speed:OnUpgrade()
	if not self.active_multiplier then
		self.active_multiplier = 1
	end

	if self.modifier then
		self.modifier:ForceRefresh()
	end
end

function yondaime_agile_speed:OnSpellStart()
	self.active_multiplier = 2
	self.modifier:ForceRefresh()
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
	return self.bonus_damage
end

function modifier_yondaime_agile_speed_passive:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed_perc
end

function modifier_yondaime_agile_speed_passive:OnCreated()
	local ability = self:GetAbility()
	self:GetAbility().modifier = self
	self.bonus_damage_ms_perc = self:GetAbility():GetSpecialValueFor("bonus_damage_ms_percent")
	self.bonus_movespeed_perc = self:GetAbility():GetSpecialValueFor("bonus_ms_percentage")

	self.bonus_damage = self:GetParent():GetIdealSpeed() / 100 * self.bonus_damage_ms_perc
	self:SetStackCount(self.bonus_damage)

	self:StartIntervalThink(0.1)
end

function modifier_yondaime_agile_speed_passive:OnRefresh()
	local ability = self:GetAbility()
	print(self:GetParent():HasModifier("modifier_yondaime_agile_speed_active"))
	if self:GetParent():HasModifier("modifier_yondaime_agile_speed_active") then
		self.bonus_damage_ms_perc = self:GetAbility():GetSpecialValueFor("bonus_damage_ms_percent_active")
		self.bonus_movespeed_perc = self:GetAbility():GetSpecialValueFor("bonus_ms_percentage_active")
	else
		self.bonus_damage_ms_perc = self:GetAbility():GetSpecialValueFor("bonus_damage_ms_percent")
		self.bonus_movespeed_perc = self:GetAbility():GetSpecialValueFor("bonus_ms_percentage")
	end

	self.movement_speed = self:GetParent():GetIdealSpeed()
	self.bonus_damage = self.movement_speed / 100 * self.bonus_damage_ms_perc
	self:SetStackCount(self.bonus_damage)
end

function modifier_yondaime_agile_speed_passive:OnIntervalThink()
	if self:GetParent():GetIdealSpeed() ~= self.movement_speed then
		self.movement_speed = self:GetParent():GetIdealSpeed()
		self.bonus_damage = self.movement_speed / 100 * self.bonus_damage_ms_perc
		self:SetStackCount(self.bonus_damage)
	end
end

modifier_yondaime_agile_speed_active = class({})

function modifier_yondaime_agile_speed_active:IsHidden() return false end
function modifier_yondaime_agile_speed_active:IsDebuff() return false end
function modifier_yondaime_agile_speed_active:IsPurgable() return true end

function modifier_yondaime_agile_speed_active:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local modifier = ability:GetCaster():FindModifierByName(ability:GetIntrinsicModifierName())
	modifier.bonus_damage_ms_perc = ability:GetSpecialValueFor("bonus_damage_ms_percent_active")
	modifier.bonus_movespeed_perc = ability:GetSpecialValueFor("bonus_ms_percentage_active")
	self:GetCaster():EmitSound("minato_flash_cast")
end


function modifier_yondaime_agile_speed_active:OnRemoved() 
	if not IsServer() then return end
	local ability = self:GetAbility()
	local modifier = ability:GetCaster():FindModifierByName(ability:GetIntrinsicModifierName())
	modifier.bonus_damage_ms_perc = ability:GetSpecialValueFor("bonus_damage_ms_percent")
	modifier.bonus_movespeed_perc = ability:GetSpecialValueFor("bonus_ms_percentage")
end

function modifier_yondaime_agile_speed_active:GetEffectName()
	return "particles/units/heroes/yondaime/minato_flash_active.vpcf"
end