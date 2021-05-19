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
end

LinkLuaModifier("modifier_senei_jyashu", "scripts/vscripts/heroes/anko/anko_senei_jyashu.lua", LUA_MODIFIER_MOTION_NONE)

function anko_senei_jyashu:GetIntrinsicModifierName()
	return "modifier_senei_jyashu"
end

function anko_senei_jyashu:OnProjectileHit(hTarget, vLocation)
	if not IsServer() then return end

	if hTarget then
		local damage = self:GetSpecialValueFor("snake_damage") + self:GetCaster():FindTalentValue("special_bonus_anko_3")

		ApplyDamage({
			attacker = self:GetCaster(),
			damage_type = self:GetAbilityDamageType(),
			ability = self,
			victim = hTarget,
			damage = damage,
		})

		hTarget:EmitSound("Hero_Medusa.MysticSnake.Target")
	end
end

modifier_senei_jyashu = modifier_senei_jyashu or class({})

function modifier_senei_jyashu:IsHidden() return true end

function modifier_senei_jyashu:DeclareFunctions() return {
	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
} end

function modifier_senei_jyashu:OnCreated()
	if not IsServer() then return end

	self.interval_upgraded = false
	self.interval = self:GetAbility():GetSpecialValueFor("snake_damage_interval") + self:GetCaster():FindTalentValue("special_bonus_anko_4")

	self:StartIntervalThink(self.interval)
end

function modifier_senei_jyashu:OnIntervalThink()
	if not self:GetParent():IsRealHero() then return end

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

	target_enemy:EmitSound("Hero_Medusa.MysticSnake.Cast")
end

function modifier_senei_jyashu:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("senei_jyashu_magic_resist")
end
