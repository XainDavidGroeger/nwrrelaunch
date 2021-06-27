-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
sai_snake_entanglement = class({})
LinkLuaModifier( "modifier_sai_snake_entanglement_thinker", "heroes/sai/sai_snake_entanglement", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sai_snake_entanglement_debuff", "heroes/sai/sai_snake_entanglement", LUA_MODIFIER_MOTION_NONE )
--link modifier with abyliti
--mod name/ filepath

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function sai_snake_entanglement:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )--get var by name
end

--------------------------------------------------------------------------------
-- Ability Start
function sai_snake_entanglement:OnSpellStart()--evt; when animation completed
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local vector = point-caster:GetOrigin()--direction for prejectile

	-- load data
	local projectile_name = "particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin_proj.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	--distance based stuff (abnd speed) its all int and everityng else float
	local projectile_distance = vector:Length2D()--dont need z chek next line
	local projectile_direction = vector
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()--because direction doesnt need to scale the distance when multiplyed by length

	-- create ink projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),--origin witou z coords (2d)
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_NONE,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = 0, --size
	    fEndRadius = 0, --size
		vVelocity = projectile_direction * projectile_speed, --this why jwe normalized it
	}
	ProjectileManager:CreateLinearProjectile(info) --init projectile. launches

	-- play effects
	--self:PlayEffects( point )--just sound fx and visuals
end
--------------------------------------------------------------------------------
-- Projectile
function sai_snake_entanglement:OnProjectileHit( target, location ) -- it can intercept before final target
	-- should be no target
	if target then return false end --do nothing but not dissapera; true disappears.https://moddota.com/api/#!/vscripts?search=OnProjectileHit

	-- references
	local duration = self:GetSpecialValueFor( "duration" )

	-- create thinker dummy nuit in place. aura somwhere with given modifier
	CreateModifierThinker(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_sai_snake_entanglement_thinker", -- modifier name
		{ duration = duration }, -- kv
		location,
		self:GetCaster():GetTeamNumber(), --default needed
		false --dnot touch
	)
end

------------------------------------------------------------------------------
function sai_snake_entanglement:PlayEffects( point )--this is gonna be had
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_viper/viper_nethertoxin_proj.vpcf"
	local sound_cast = "Hero_Viper.Nethertoxin.Cast"

	-- Get Data
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end


modifier_sai_snake_entanglement_thinker= class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sai_snake_entanglement_thinker:IsHidden() --shown or not as debuff
	return true
end

function modifier_sai_snake_entanglement_thinker:IsDebuff() --type of
	return true
end

function modifier_sai_snake_entanglement_thinker:IsStunDebuff() 
	return false
end

function modifier_sai_snake_entanglement_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
-- in modifier self:GetAbility() get owning ability
function modifier_sai_snake_entanglement_thinker:OnCreated( kv )
	self.radius= self:GetAbility():GetSpecialValueFor("radius") --initialize radius here


end

function modifier_sai_snake_entanglement_thinker:OnRefresh( kv )

end

function modifier_sai_snake_entanglement_thinker:OnRemoved()
end

function modifier_sai_snake_entanglement_thinker:OnDestroy()

end
-------------------------------------------------------------------------------
-- Aura Effects
function modifier_sai_snake_entanglement_thinker:IsAura()
	return true
end

function modifier_sai_snake_entanglement_thinker:GetModifierAura()-- for the aoe effect we make new modfier effect
	return "modifier_sai_snake_entanglement_debuff"
end

function modifier_sai_snake_entanglement_thinker:GetAuraRadius()
	return self.radius
end

function modifier_sai_snake_entanglement_thinker:GetAuraDuration() --duration for aura fdebuff time (float bcus time)
	return 2.0
end

function modifier_sai_snake_entanglement_thinker:GetAuraSearchTeam() --team 
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_sai_snake_entanglement_thinker:GetAuraSearchType() --targer
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC -- not array. with +
end
-----------------------------

modifier_sai_snake_entanglement_debuff= class({})

-- Classifications defaults required
function modifier_sai_snake_entanglement_debuff:IsHidden() --shown or not as debuff
	return false
end

function modifier_sai_snake_entanglement_debuff:IsDebuff() --type of
	return true
end

function modifier_sai_snake_entanglement_debuff:IsStunDebuff() 
	return false
end

function modifier_sai_snake_entanglement_debuff:IsPurgable()
	return false
end

function modifier_sai_snake_entanglement_debuff:OnCreated( kv )
	self.ms_slow_percentage_per_stack= self:GetAbility():GetSpecialValueFor("ms_slow_percentage_per_stack") --initialize 

end
----------------------------------
--MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE in negative is debuff is the value to mod
--getter GetModifierMoveSpeedBonus_Percentage

function modifier_sai_snake_entanglement_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end	

function modifier_sai_snake_entanglement_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow_percentage_per_stack *-1
end	