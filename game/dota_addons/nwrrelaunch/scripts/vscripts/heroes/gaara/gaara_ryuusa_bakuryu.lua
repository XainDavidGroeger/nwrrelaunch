gaara_ryuusa_bakuryu = gaara_ryuusa_bakuryu or class({})

LinkLuaModifier("modifier_gaara_sandstorm_thinker", "heroes/gaara/gaara_ryuusa_bakuryu.lua", LUA_MODIFIER_MOTION_NONE)

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

function gaara_ryuusa_bakuryu:OnSpellStart()

	-- Ability properties    
	self.caster = self:GetCaster()
	self.ability = self

	-- Ability specials
	self.damage = self.ability:GetSpecialValueFor("thinker_damage")
	self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
	self.radius = self.ability:GetSpecialValueFor("radius")

	if self:GetCaster():FindAbilityByName("special_bonus_gaara_2") ~= nil then
		if self:GetCaster():FindAbilityByName("special_bonus_gaara_2"):GetLevel() > 0 then
			self.radius =  self.radius + 80
		end
	end



	self.damage_interval = self.ability:GetSpecialValueFor("thinker_interval")

	self.ability_target_team	= self.ability:GetAbilityTargetTeam()
	self.ability_target_type	= self.ability:GetAbilityTargetType()
	self.ability_target_flags	= self.ability:GetAbilityTargetFlags()

	Timers:CreateTimer(0.3, function()
		local caster = self:GetCaster()
		local ability = self
		local target_point = self:GetCursorPosition()
		local team_id = caster:GetTeamNumber()
		-- Special Variables
		local duration = self:GetLevelSpecialValueFor("duration", (self:GetLevel() - 1))

		-- Find all enemies in the radius
		local units = FindUnitsInRadius(self.caster:GetTeamNumber(),
		target_point,
		nil,
		self.radius,
		self.ability_target_team,
		self.ability_target_type,
		self.ability_target_flags,
		FIND_ANY_ORDER,
		false)

		for _,enemy in pairs(units) do
			enemy:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = self.stun_duration})
		end

		local thinker = CreateModifierThinker(caster, self, "modifier_gaara_sandstorm_thinker", {duration = duration}, target_point, team_id, false)
	end)

end


modifier_gaara_sandstorm_thinker = modifier_gaara_sandstorm_thinker or class({})

function modifier_gaara_sandstorm_thinker:IsAura()
	return true
end

function modifier_gaara_sandstorm_thinker:OnCreated(keys)
	if IsServer() then
		-- Ability specials

		self.caster = self:GetCaster()
		self.thinker = self:GetParent()
		self.ability = self:GetAbility()
		
		self.ability_target_team	= self.ability:GetAbilityTargetTeam()
		self.ability_target_type	= self.ability:GetAbilityTargetType()
		self.ability_target_flags	= self.ability:GetAbilityTargetFlags()

		self.thinker_loc = self.thinker:GetAbsOrigin()

		self.damage = self.ability:GetSpecialValueFor("thinker_damage")
		self.radius = self.ability:GetSpecialValueFor("radius")

		if self:GetCaster():FindAbilityByName("special_bonus_gaara_2") ~= nil then
			if self:GetCaster():FindAbilityByName("special_bonus_gaara_2"):GetLevel() > 0 then
				self.radius =  self.radius + 80
			end
		end
		

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

		Timers:CreateTimer(2, function()
			ParticleManager:DestroyParticle(self.particle_sandstorm_fx, false)
			ParticleManager:ReleaseParticleIndex(self.particle_sandstorm_fx)   
			StopSoundOn(sound_loop, self.thinker)
			StopSoundOn(sound_darude, self.thinker)  
		end)

		self:StartIntervalThink(0.45)
	end
end

function modifier_gaara_sandstorm_thinker:OnDestroy(keys)
	if IsServer() then
		local thinker = self:GetParent()
		local sound_loop = "Ability.SandKing_SandStorm.loop"
		thinker:StopSound("sound_loop")
		ParticleManager:DestroyParticle(self.particle_sandstorm_fx, true)
		ParticleManager:ReleaseParticleIndex(self.particle_sandstorm_fx)
	end
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
	false)

	for _,enemy in pairs(units) do
		-- Deal damage
		local damageTable = {victim = enemy,
		attacker = self.caster, 
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
		}

		ApplyDamage(damageTable)  
	end
end
