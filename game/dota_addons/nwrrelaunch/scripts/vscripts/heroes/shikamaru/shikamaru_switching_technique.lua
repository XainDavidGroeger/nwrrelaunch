shikamaru_switching_technique = shikamaru_switching_technique or class({})

LinkLuaModifier("modifier_shikamaru_switching_thinker", "heroes/shikamaru/shikamaru_switching_technique.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_switching_technique_flash_debuff", "heroes/shikamaru/shikamaru_switching_technique.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_switching_technique_debuff", "heroes/shikamaru/shikamaru_switching_technique.lua", LUA_MODIFIER_MOTION_NONE)

function shikamaru_switching_technique:Precache( context )
    PrecacheResource( "soundfile", "soundevents/heroes/shikamaru/shikamaru_stitch_area.vsndevts", context )
end


function shikamaru_switching_technique:GetAbilityTextureName()
	return "shikamaru_switching_technique"
end
-------------------------------------------
function shikamaru_switching_technique:GetAOERadius()
	local extraaoe = 0
	if self:GetCaster():FindAbilityByName("special_bonus_shikamaru_6") ~= nil then
		if self:GetCaster():FindAbilityByName("special_bonus_shikamaru_6"):GetLevel() > 0 then
			extraaoe =  300
		end
	end
	return self:GetSpecialValueFor("radius") + extraaoe
end

function shikamaru_switching_technique:GetChannelTime()
	return self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_shikamaru_1")
end

function shikamaru_switching_technique:ProcsMagicStick()
    return true
end

function shikamaru_switching_technique:OnSpellStart()

	-- Ability properties    
	self.caster = self:GetCaster()
	self.ability = self

	self.caster:EmitSound("shikamaru_stitch_talking")
	--self.caster:EmitSound("sounds/weapons/hero/sand_king/sand_king_sandstorm_loop.vsnd")

	-- Ability specials
	self.damage = self.ability:GetSpecialValueFor("damage_per_interval")
	self.radius = self.ability:GetSpecialValueFor("radius") + self.caster:FindTalentValue("special_bonus_shikamaru_6")
	self.duration = self.ability:GetSpecialValueFor("duration") + self.caster:FindTalentValue("special_bonus_shikamaru_1")

	self.team_id = self.caster:GetTeamNumber()
	
	self.target_point = self:GetCursorPosition()
	self.interval_time = self.ability:GetSpecialValueFor("interval_time")

	self.ability_target_team	= self.ability:GetAbilityTargetTeam()
	self.ability_target_type	= self.ability:GetAbilityTargetType()
	self.ability_target_flags	= self.ability:GetAbilityTargetFlags()

	-- Add sandstorm particles
	local particle_sandstorm = "particles/units/heroes/shikamaru/shikamaru_shadow_stitching.vpcf"
	self.particle_sandstorm_fx = ParticleManager:CreateParticle(particle_sandstorm, PATTACH_WORLDORIGIN, self.thinker)
	ParticleManager:SetParticleControl(self.particle_sandstorm_fx, 0, self.target_point)
	ParticleManager:SetParticleControl(self.particle_sandstorm_fx, 1, Vector(self.radius, self.radius, 0))

	self.thinker = CreateModifierThinker(caster, self, "modifier_shikamaru_switching_thinker", {duration = self.duration}, self.target_point, self.team_id, false)
end

function shikamaru_switching_technique:OnChannelFinish(bInterrupted)
	if not IsServer() then return end

	local sound_loop = "Ability.SandKing_SandStorm.loop"
	self.thinker:StopSound("sound_loop")
	ParticleManager:DestroyParticle(self.particle_sandstorm_fx, true)
	ParticleManager:ReleaseParticleIndex(self.particle_sandstorm_fx)
	StopSoundOn(sound_loop, self.thinker)
	StopSoundOn(sound_darude, self.thinker)  
	self.thinker:Destroy()

	-- Find all enemies in the radius
	local units = FindUnitsInRadius(
		self.team_id,
		self.target_point,
		nil,
		self.radius,
		self.ability_target_team,
		self.ability_target_type,
		self.ability_target_flags,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(units) do
		enemy:RemoveModifierByName("modifier_switching_technique_debuff")
		enemy:RemoveModifierByName("modifier_switching_technique_flash_debuff")
	end

end

modifier_shikamaru_switching_thinker = modifier_shikamaru_switching_thinker or class({})

function modifier_shikamaru_switching_thinker:IsAura()
	return true
end

function modifier_shikamaru_switching_thinker:OnCreated(keys)
	if IsServer() then
		-- Ability specials

		self.caster = self:GetCaster()
		self.thinker = self:GetParent()
		self.ability = self:GetAbility()
		self.old_caster = self:GetCaster()
		
		self.ability_target_team	= self.ability:GetAbilityTargetTeam()
		self.ability_target_type	= self.ability:GetAbilityTargetType()
		self.ability_target_flags	= self.ability:GetAbilityTargetFlags()

		self.thinker_loc = self.thinker:GetAbsOrigin()

		self.damage = self.ability:GetSpecialValueFor("damage_per_interval")
		self.radius = self.ability:GetSpecialValueFor("radius")
		self.interval_time = self.ability:GetSpecialValueFor("interval_time")

		local sound_cast = "Ability.SandKing_SandStorm.start"
		local sound_loop = "Ability.SandKing_SandStorm.loop"
		local sound_darude = "Imba.SandKingSandStorm"

		-- Play cast sound
		self.thinker:EmitSound(sound_cast)
		self.thinker:EmitSound(sound_loop)

		self:StartIntervalThink(self.interval_time)
		EmitSoundOn("shikamaru_stitch_area", self.thinker)

	end
end

function modifier_shikamaru_switching_thinker:OnIntervalThink()

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
		local damageTable = {
			victim = enemy,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = nil,
			attacker = self:GetAbility():GetCaster(), 
			ability = self:GetAbility()
		}

		if enemy:IsMagicImmune() == false then 
			ApplyDamage(damageTable)

			enemy:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_switching_technique_debuff", {})
			if enemy:HasModifier("modifier_flash_bomb_debuff") then
				enemy:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_switching_technique_flash_debuff", {})
			end
		end
	end
end

function modifier_shikamaru_switching_thinker:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true
	}
end

function modifier_shikamaru_switching_thinker:OnDestroy(keys)
	if IsServer() then
		-- local thinker = self:GetParent()
		StopSoundOn("shikamaru_stitch_area", self.thinker)
		ParticleManager:DestroyParticle(self.particle_sandstorm_fx, true)
		ParticleManager:ReleaseParticleIndex(self.particle_sandstorm_fx)
	end
end

modifier_switching_technique_debuff = class({})

function modifier_switching_technique_debuff:IsHidden()
	return false
end

function modifier_switching_technique_debuff:IsDebuff()
	return true
end

function modifier_switching_technique_debuff:IsStunDebuff()
	return false
end

function modifier_switching_technique_debuff:IsPurgable()
	return true
end

function modifier_switching_technique_debuff:OnCreated( kv )
end

function modifier_switching_technique_debuff:OnRemoved()
end

function modifier_switching_technique_debuff:OnDestroy()
end

function modifier_switching_technique_debuff:CheckState()
	return {
		[MODIFIER_STATE_DISARMED]	= true,
		[MODIFIER_STATE_ROOTED]	= true,
	}
end



modifier_switching_technique_flash_debuff = class({})

-- Classifications
function modifier_switching_technique_flash_debuff:IsHidden()
	return false
end

function modifier_switching_technique_flash_debuff:IsDebuff()
	return true
end

function modifier_switching_technique_flash_debuff:IsStunDebuff()
	return false
end

function modifier_switching_technique_flash_debuff:IsPurgable()
	return true
end

function modifier_switching_technique_flash_debuff:OnCreated( kv )
end

function modifier_switching_technique_flash_debuff:OnRemoved()
end

function modifier_switching_technique_flash_debuff:OnDestroy()
end

function modifier_switching_technique_flash_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED]	= true,
	}
end

