--[[Author: DigitalG
	Date: April 29, 2021
	Creates a puppet that grows in level and has 4 different skills]]


kankuro_summon_karasu = class({})

LinkLuaModifier("modifier_karasu_talent_attack_speed_bonus", "heroes/kankuro/summon_karasu", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_karasu_base_mana", "heroes/kankuro/summon_karasu", LUA_MODIFIER_MOTION_NONE)

function kankuro_summon_karasu:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function kankuro_summon_karasu:ProcsMagicStick()
	return true
end

function kankuro_summon_karasu:OnSpellStart()

	--Kill old Karasu if present
	if self.karasu ~= nil then
		self.karasu:ForceKill(false)
	end

	local caster = self:GetCaster()
	local caster_origin = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("puppet_duration")
	--Creates the Puppet next to the Caster
	local karasu_unit  = CreateUnitByName("npc_karasu", caster_origin + RandomVector(100), true, caster, caster, caster:GetTeamNumber())

	--Save pointer
	self.karasu = karasu_unit
	self.karasu:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
	self.karasu:AddNewModifier(caster, self, "modifier_kill", {duration = duration})

	--Health
	local health = self:GetSpecialValueFor("total_health")
	local puppet_master_ability = caster:FindAbilityByName("kankuro_kugusta_no_jutsu")
	if puppet_master_ability ~= nil then
	    if puppet_master_ability:IsTrained() then
	    	health = health + puppet_master_ability:GetSpecialValueFor("hp_bonus")
	    end
	end
	
	self.karasu:SetBaseMaxHealth(health)
	self.karasu:ModifyHealth(health, nil, false, 0)

	--Mana
	local mana = self:GetSpecialValueFor("total_mana")
	self.karasu:AddNewModifier(caster, self, "modifier_karasu_base_mana", {duration = duration})
	self.karasu:SetMana(mana)
	

	--Attack Damage
	local min_damage = self:GetSpecialValueFor("base_damage_min")
	local max_damage = self:GetSpecialValueFor("base_damage_max")
	local bonus_damage_talent = caster:FindAbilityByName("special_bonus_kankuro_7")
	if bonus_damage_talent ~= nil then
	    if bonus_damage_talent:IsTrained() then
	    	local bonus_damage = self:GetSpecialValueFor("talent_bonus_damage")
	    	min_damage = min_damage + bonus_damage
	    	max_damage = max_damage + bonus_damage
	    end
	end

	self.karasu:SetBaseDamageMin(min_damage)
	self.karasu:SetBaseDamageMax(max_damage)

	--Move speed
	local move_speed = self:GetSpecialValueFor("move_speed")
	local talent_bonus_movespeed = caster:FindAbilityByName("special_bonus_kankuro_3")
	if talent_bonus_movespeed ~= nil then
	    if talent_bonus_movespeed:IsTrained() then
	    	move_speed = move_speed + talent_bonus_movespeed:GetSpecialValueFor("value")
	    end
	end

	self.karasu:SetBaseMoveSpeed(move_speed)

	--Attack speed
	local attack_speed_talent_ability = caster:FindAbilityByName("special_bonus_kankuro_5")
	if attack_speed_talent_ability ~= nil then
	    if attack_speed_talent_ability:IsTrained() then
	    	self.karasu:AddNewModifier(caster, self, "modifier_karasu_talent_attack_speed_bonus", {})
	    end
	end

	--Mana regen
	local base_mana_regen = self:GetSpecialValueFor("mana_regeneration")
	local mana_regen_bonus_talent_ability = caster:FindAbilityByName("special_bonus_kankuro_1")
	if mana_regen_bonus_talent_ability ~= nil then
	    if mana_regen_bonus_talent_ability:IsTrained() then
	    	base_mana_regen = base_mana_regen + mana_regen_bonus_talent_ability:GetSpecialValueFor("value")
	    end
	end

	self.karasu:SetBaseManaRegen(base_mana_regen)


	--Determine Karasu's Skills
	if (self:GetLevel() == 1) then
		self.karasu:CreatureLevelUp(1)
		self.karasu:FindAbilityByName("karasu_daggers"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_poison_gas"):SetLevel(0)
		self.karasu:FindAbilityByName("karasu_critical_strike"):SetLevel(0)
		self.karasu:FindAbilityByName("karasu_dismantle_parts"):SetLevel(0)
	elseif (self:GetLevel() == 2) then
		self.karasu:CreatureLevelUp(2)
		self.karasu:FindAbilityByName("karasu_daggers"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_poison_gas"):SetLevel(0)
		self.karasu:FindAbilityByName("karasu_critical_strike"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_dismantle_parts"):SetLevel(0)
	elseif (self:GetLevel() == 3) then
		self.karasu:CreatureLevelUp(3)
		self.karasu:FindAbilityByName("karasu_daggers"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_poison_gas"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_critical_strike"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_dismantle_parts"):SetLevel(0)
	elseif (self:GetLevel() == 4) then
		self.karasu:CreatureLevelUp(4)
		self.karasu:FindAbilityByName("karasu_daggers"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_poison_gas"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_critical_strike"):SetLevel(1)
		self.karasu:FindAbilityByName("karasu_dismantle_parts"):SetLevel(1)
	end

end

modifier_karasu_talent_attack_speed_bonus = class({})

function modifier_karasu_talent_attack_speed_bonus:OnCreated()
	self.as_bonus = self:GetAbility():GetSpecialValueFor("attack_speed_buff")
end

function modifier_karasu_talent_attack_speed_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_karasu_talent_attack_speed_bonus:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end

modifier_karasu_base_mana = class({})

function modifier_karasu_base_mana:IsPurgable() return false end
function modifier_karasu_base_mana:IsHidden() return true end


function modifier_karasu_base_mana:OnCreated()
	self.mana_bonus = self:GetAbility():GetSpecialValueFor("total_mana") - 1 
end

function modifier_karasu_base_mana:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS 
	}
end

function modifier_karasu_base_mana:GetModifierManaBonus()
	return self.mana_bonus
end

function modifier_karasu_base_mana:OnRemoved()
	self:GetAbility().karasu = nil
end