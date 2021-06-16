gaara_ryuusa_bakuryu = gaara_ryuusa_bakuryu or class({})

LinkLuaModifier("modifier_gaara_sandstorm_thinker", "heroes/gaara/gaara_ryuusa_bakuryu.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gaara_sandstorm_thinker_debuff", "heroes/gaara/gaara_ryuusa_bakuryu.lua", LUA_MODIFIER_MOTION_NONE)

function gaara_ryuusa_bakuryu:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/gaara/sandsturm.vpcf", context)
	PrecacheResource("soundfile", "soundevents/heroes/gaara/gaara_tsunami_cast.vsndevts", context)
end

function gaara_ryuusa_bakuryu:GetAbilityTextureName()
	return "gaara_ryuusa_bakuryu"
end
-------------------------------------------
function gaara_ryuusa_bakuryu:GetAOERadius()
	local extraaoe = 0

	if self:GetCaster():FindAbilityByName("special_bonus_gaara_2") ~= nil then
		if self:GetCaster():FindAbilityByName("special_bonus_gaara_2"):GetLevel() > 0 then
			extraaoe =  80
		end
	end
	
	return self:GetSpecialValueFor("radius") + extraaoe
end

function gaara_ryuusa_bakuryu:ProcsMagicStick()
    return true
end

function gaara_ryuusa_bakuryu:OnSpellStart()

	-- Ability properties    
	self.caster = self:GetCaster()

	self.caster:EmitSound("gaara_tsunami_cast")
	--self.caster:EmitSound("sounds/weapons/hero/sand_king/sand_king_sandstorm_loop.vsnd")

	-- Ability specials
	self.radius = self:GetSpecialValueFor("radius")

	if self:GetCaster():FindAbilityByName("special_bonus_gaara_2") ~= nil then
		if self:GetCaster():FindAbilityByName("special_bonus_gaara_2"):GetLevel() > 0 then
			self.radius =  self.radius + 80
		end
	end

	self.cursor_position = self:GetCursorPosition()
	self.damage_interval = self:GetSpecialValueFor("thinker_interval")

	self.ability_target_team	= self:GetAbilityTargetTeam()
	self.ability_target_type	= self:GetAbilityTargetType()
	self.ability_target_flags	= self:GetAbilityTargetFlags()


	local caster = self:GetCaster()
	local ability = self
	local target_point = self.cursor_position
	local team_id = caster:GetTeamNumber()
	-- Special Variables
	self.aura_duration = self:GetSpecialValueFor("duration")

	-- Find all enemies in the radius
	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		target_point,
		nil,
		self.radius,
		self.ability_target_team,
		self.ability_target_type,
		self.ability_target_flags,
		FIND_ANY_ORDER,
		false
	)

	local thinker = CreateModifierThinker(
		caster, 
		self, 
		"modifier_gaara_sandstorm_thinker", 
		{duration = self.aura_duration}, 
		target_point, 
		team_id, 
		false
	)
end


modifier_gaara_sandstorm_thinker = modifier_gaara_sandstorm_thinker or class({})

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_gaara_sandstorm_thinker:IsAura()
	return true
end

function modifier_gaara_sandstorm_thinker:GetModifierAura()
	return "modifier_gaara_sandstorm_thinker_debuff"
end

function modifier_gaara_sandstorm_thinker:GetAuraRadius()
	return self.radius
end

function modifier_gaara_sandstorm_thinker:GetAuraDuration()
	return 0.1
end

function modifier_gaara_sandstorm_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_gaara_sandstorm_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_gaara_sandstorm_thinker:GetAuraSearchFlags()
	return 0
end

function modifier_gaara_sandstorm_thinker:OnCreated(keys)
	-- Ability specials

	self.caster = self:GetCaster()
	self.thinker = self:GetParent()
	self.ability = self:GetAbility()
	
	self.ability_target_team	= self.ability:GetAbilityTargetTeam()
	self.ability_target_type	= self.ability:GetAbilityTargetType()
	self.ability_target_flags	= self.ability:GetAbilityTargetFlags()

	self.thinker_loc = self.thinker:GetAbsOrigin()
	self.thinker_interval = self.ability:GetSpecialValueFor("thinker_interval")

	self.damage_per_tick = (self.ability:GetAbilityDamage() * self.thinker_interval) / self.ability.aura_duration
	self.radius = self.ability:GetSpecialValueFor("radius")

	if self:GetCaster():FindAbilityByName("special_bonus_gaara_2") ~= nil then
		if self:GetCaster():FindAbilityByName("special_bonus_gaara_2"):GetLevel() > 0 then
			self.radius =  self.radius + 80
		end
	end

	self.damage_table = {
		attacker = self.caster, 
		damage = self.damage_per_tick,
		damage_type = self.ability:GetAbilityDamageType(),
		damage_flags = 0,
		ability = self
	}
	

	self.damage_interval = self.ability:GetSpecialValueFor("thinker_interval")

	local sound_cast = "Ability.SandKing_SandStorm.start"
	local sound_loop = "Ability.SandKing_SandStorm.loop"
	local sound_darude = "Imba.SandKingSandStorm"
	local particle_sandstorm = "particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf"

	-- Play cast sound
	self.thinker:EmitSound(sound_cast)
	self.thinker:EmitSound(sound_loop)

	-- Add sandstorm particles
	self.particle_sandstorm_fx = ParticleManager:CreateParticle(particle_sandstorm, PATTACH_WORLDORIGIN, self.thinker)
	ParticleManager:SetParticleControl(self.particle_sandstorm_fx, 0, self.thinker:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle_sandstorm_fx, 1, Vector(self.radius, self.radius, 0))

	Timers:CreateTimer(3, function()
		ParticleManager:DestroyParticle(self.particle_sandstorm_fx, false)
		ParticleManager:ReleaseParticleIndex(self.particle_sandstorm_fx)   
		StopSoundOn(sound_loop, self.thinker)
		StopSoundOn(sound_darude, self.thinker)  
	end)

	self:StartIntervalThink(self.thinker_interval)

end

function modifier_gaara_sandstorm_thinker:OnDestroy(keys)

	local thinker = self:GetParent()
	local sound_loop = "Ability.SandKing_SandStorm.loop"
	thinker:StopSound("sound_loop")
	ParticleManager:DestroyParticle(self.particle_sandstorm_fx, true)
	ParticleManager:ReleaseParticleIndex(self.particle_sandstorm_fx)

end

function modifier_gaara_sandstorm_thinker:OnIntervalThink()

	-- Find all enemies in the radius
	local units = FindUnitsInRadius(self.thinker:GetTeamNumber(),
		self.thinker_loc,
		nil,
		self.radius,
		self.ability_target_team,
		self.ability_target_type,
		self.ability_target_flags,
		FIND_ANY_ORDER,
		false
	)


	for _,enemy in pairs(units) do
		-- Deal damage
		self.damage_table.victim = enemy
		print(self.damage_table)
		ApplyDamage(self.damage_table)  
	end
end


modifier_gaara_sandstorm_thinker_debuff = class({})

function modifier_gaara_sandstorm_thinker_debuff:OnCreated()
	local ability = self:GetAbility()
	self.slow_perc = ability:GetSpecialValueFor("slow_perc")
end

function modifier_gaara_sandstorm_thinker_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_gaara_sandstorm_thinker_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self.slow_perc
	-- return -10
end