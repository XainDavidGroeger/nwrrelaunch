--[[Author: Zenicus
	Modified from Bristleback's bristleback ability
	Date: 11.05.2015.
	Converted from datadriven to lua by EarthSalamander
	Date: 27.04.2021
]]
--------------------------------------------------------------------------------

anko_senei_jyashu = anko_senei_jyashu or class({})

function anko_senei_jyashu:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_medusa/medusa_mystic_snake_cast.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf", context)
	PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context)
	PrecacheResource("soundfile","soundevents/heroes/anko/anko_passive_cast.vsndevts", context)
	PrecacheResource("soundfile","soundevents/heroes/anko/anko_passive_impact.vsndevts", context)
end

LinkLuaModifier("modifier_senei_jyashu_passive", "scripts/vscripts/heroes/anko/anko_senei_jyashu.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_senei_jyashu_active", "scripts/vscripts/heroes/anko/anko_senei_jyashu.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_senei_jyashu_stacks", "scripts/vscripts/heroes/anko/anko_senei_jyashu.lua", LUA_MODIFIER_MOTION_NONE)

function anko_senei_jyashu:GetIntrinsicModifierName()
	return "modifier_senei_jyashu_passive"
end

function anko_senei_jyashu:OnProjectileHit(hTarget, vLocation)
	if not IsServer() then return end

	if hTarget then
		local damage = self:GetSpecialValueFor("snake_damage") + self:GetCaster():FindTalentValue("special_bonus_anko_3")
		local max_stacks = self:GetSpecialValueFor("max_stacks")
		local damage_per_stack = self:GetSpecialValueFor("damage_per_stack")
		local stacks_duration = self:GetSpecialValueFor("stacks_duration")

		local stack_modifier = hTarget:FindModifierByName("modifier_senei_jyashu_stacks")
		local stacks

		if stack_modifier then
			stacks = stack_modifier:GetStackCount()

			if stacks < max_stacks then
				stack_modifier:IncrementStackCount()
			else
			end
			stack_modifier:ForceRefresh()
		else
			local new_stack_modifier = hTarget:AddNewModifier(
				self:GetCaster(), 
				self, 
				"modifier_senei_jyashu_stacks", 
				{duration = stacks_duration})
			new_stack_modifier:SetStackCount(1)
		end

		if stacks then
			damage = damage + stacks*damage_per_stack
		end

		ApplyDamage({
			attacker = self:GetCaster(),
			damage_type = self:GetAbilityDamageType(),
			ability = self,
			victim = hTarget,
			damage = damage,
		})

		hTarget:EmitSound("anko_passive_impact")

	end
end

function anko_senei_jyashu:OnUpgrade()
	local modifier = self:GetCaster():FindModifierByName("modifier_senei_jyashu_passive")
	if modifier then
		modifier:ForceRefresh()
	end
end

function anko_senei_jyashu:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("active_duration")

	caster:AddNewModifier(caster, self, "modifier_senei_jyashu_active", {duration = duration})
end

modifier_senei_jyashu_passive = modifier_senei_jyashu_passive or class({})

function modifier_senei_jyashu_passive:IsHidden() return true end

function modifier_senei_jyashu_passive:DeclareFunctions() return {
	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
} end

function modifier_senei_jyashu_passive:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("senei_jyashu_magic_resist")
end

function modifier_senei_jyashu_passive:OnRefresh(table)
	self.magic_resist = self:GetAbility():GetSpecialValueFor("senei_jyashu_magic_resist")
end

function modifier_senei_jyashu_passive:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end


modifier_senei_jyashu_active = class({})

function modifier_senei_jyashu_active:IsHidden() return false end
function modifier_senei_jyashu_active:IsBuff() return true end
function modifier_senei_jyashu_active:IsPurgable() return true end


function modifier_senei_jyashu_active:OnCreated()
	if not IsServer() then return end

	self.interval_upgraded = false
	self.interval = self:GetAbility():GetSpecialValueFor("snake_damage_interval") + self:GetCaster():FindTalentValue("special_bonus_anko_4")

	self:StartIntervalThink(self.interval)
end

function modifier_senei_jyashu_active:OnIntervalThink()
	if not self:GetParent():IsRealHero() or self:GetParent():IsAlive() == false then return end

	if self.interval_upgraded == false and self:GetParent():HasTalent("special_bonus_anko_4") then
		self.interval_upgraded = true
		self.interval = self:GetAbility():GetSpecialValueFor("snake_damage_interval") + self:GetParent():FindTalentValue("special_bonus_anko_4")

		self:StartIntervalThink(self.interval)
		self:OnIntervalThink()

		return
	end

	local ability = self:GetAbility()
	local origin = self:GetParent():GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("seek_radius")

	-- Search for Targets based on range
	local full_enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		origin,
		nil,
		radius,
		ability:GetAbilityTargetTeam(),
		DOTA_UNIT_TARGET_HERO,
		ability:GetAbilityTargetFlags(),
		FIND_ANY_ORDER,
		false
	)

	if (#full_enemies < 1) then
		--search for creeps
		full_enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			origin,
			nil,
			radius,
			ability:GetAbilityTargetTeam(),
			DOTA_UNIT_TARGET_BASIC,
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)
		if (#full_enemies < 1) then
			return
		end
	end

	--local target_enemy
	local rnd = RandomInt(1, #full_enemies)
	local target_enemy = full_enemies[rnd]

	if not target_enemy then
		return
	end

	-- Create the projectile
	local projectile_info = 
	{
		EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf",
		Ability = ability,
		vSpawnOrigin = origin,
		Target = target_enemy,
		Source = self:GetParent(),
		bHasFrontalCone = false,
		iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"),
		bReplaceExisting = true,
		bProvidesVision = true,
		iVisionTeamNumber = self:GetParent():GetTeamNumber()
	}

	ProjectileManager:CreateTrackingProjectile(projectile_info)

	self:GetCaster():EmitSound("anko_passive_cast")
end


modifier_senei_jyashu_stacks = class({})

function modifier_senei_jyashu_stacks:OnCreated()

end