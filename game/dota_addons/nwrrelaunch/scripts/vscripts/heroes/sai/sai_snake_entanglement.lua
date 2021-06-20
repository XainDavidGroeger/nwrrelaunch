sai_snake_entanglement = sai_snake_entanglement or class({})

LinkLuaModifier("modifier_sai_snake_entanglement_thinker", "heroes/sai/sai_snake_entanglement.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_snake_entanglement_debuff", "heroes/sai/sai_snake_entanglement.lua", LUA_MODIFIER_MOTION_NONE)

function sai_snake_entanglement:Precache( context )
    PrecacheResource( "soundfile", "soundevents/heroes/shikamaru/shikamaru_stitch_area.vsndevts", context )
end

function sai_snake_entanglement:GetAbilityTextureName()
	return "sai_snake_entanglement"
end
-------------------------------------------
function sai_snake_entanglement:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function sai_snake_entanglement:ProcsMagicStick()
    return true
end

function sai_snake_entanglement:OnSpellStart()

	-- Ability properties    
	self.caster = self:GetCaster()
	self.ability = self

	self.caster:EmitSound("shikamaru_stitch_talking")

	-- Ability specials
	self.radius = self.ability:GetSpecialValueFor("radius")
	self.duration = self.ability:GetSpecialValueFor("duration")

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

	self.thinker = CreateModifierThinker(caster, self, "modifier_sai_snake_entanglement_thinker", {duration = self.duration}, self.target_point, self.team_id, false)
end

modifier_sai_snake_entanglement_thinker = modifier_sai_snake_entanglement_thinker or class({})

function modifier_sai_snake_entanglement_thinker:IsAura()
	return true
end

function modifier_sai_snake_entanglement_thinker:OnCreated(keys)
	if IsServer() then
		-- Ability specials

		self.caster = self:GetCaster()
		self.thinker = self:GetParent()
		self.ability = self:GetAbility()
		self.old_caster = self:GetCaster()
		

		self.thinker_loc = self.thinker:GetAbsOrigin()

		self.radius = self.ability:GetSpecialValueFor("radius")
		self.interval_time = self.ability:GetSpecialValueFor("interval_time")
		self.debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")
		self.ms_slow_percentage_per_stack = self.ability:GetSpecialValueFor("ms_slow_percentage_per_stack")

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

function modifier_sai_snake_entanglement_thinker:OnIntervalThink()

	-- Find all enemies in the radius
	local units = FindUnitsInRadius(self.thinker:GetTeamNumber(),
		self.thinker_loc,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(units) do
		if enemy:IsMagicImmune() == false then 
			if enemy:HasModifier("modifier_sai_snake_entanglement_debuff") === false then
				enemy:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_sai_snake_entanglement_debuff", {duration = self.debuff_duration})
				local debuff = enemy:FindModifierByNameAndCaster("modifier_sai_snake_entanglement_debuff", self:GetAbility():GetCaster())
				if debuff ~= nil then
					debuff:SetStackCount(debuff:GetStackCount() + self.ms_slow_percentage_per_stack) 
				end
			else
			end
		end
	end
end

function modifier_sai_snake_entanglement_thinker:OnDestroy(keys)
	if IsServer() then
		-- local thinker = self:GetParent()
		StopSoundOn("shikamaru_stitch_area", self.thinker)
		--ParticleManager:DestroyParticle(self.particle_sandstorm_fx, true)
		--ParticleManager:ReleaseParticleIndex(self.particle_sandstorm_fx)
	end
end

modifier_sai_snake_entanglement_debuff = class({})

function modifier_sai_snake_entanglement_debuff:IsHidden()
	return false
end

function modifier_sai_snake_entanglement_debuff:IsDebuff()
	return true
end

function modifier_sai_snake_entanglement_debuff:IsStunDebuff()
	return false
end

function modifier_sai_snake_entanglement_debuff:IsPurgable()
	return true
end

function modifier_sai_snake_entanglement_debuff:OnCreated()
	self.turn_rate_slow = self:GetAbility():GetSpecialValueFor( "turn_rate_slow_percentage" )
	self:SetStackCount(self:GetAbility():GetSpecialValueFor( "ms_slow_percentage_per_stack" ))
end

function modifier_sai_snake_entanglement_debuff:OnRemoved()
end

function modifier_sai_snake_entanglement_debuff:OnDestroy()
end

function modifier_sai_snake_entanglement_debuff:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	MODIFIER_PROPERTY_TURN_RATE_OVERRIDE,
} end

function modifier_sai_snake_entanglement_debuff:GetModifierMoveSpeedBonus_Percentage()
	return (-1) * self:GetStackCount()
end

function modifier_sai_snake_entanglement_debuff:GetModifierTurnRate_Override()
	return 1 - self.turn_rate_slow
end
