-- --[[Author: Zenicus
-- 	Date: December 5, 2015
-- 	Karasu's Dagger Skill, shoots out daggers to nearby enemies]]
-- function karasu_daggers( keys )

-- 	local caster = keys.caster
-- 	local player = caster:GetPlayerOwnerID()
-- 	local ability = keys.ability
-- 	local radius = ability:GetSpecialValueFor("radius")

-- 	local team = caster:GetTeamNumber()
-- 	local caster_location = caster:GetAbsOrigin()
-- 	local origin = caster:GetAbsOrigin()
-- 	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
-- 	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
-- 	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
-- 	local iOrder = FIND_ANY_ORDER

-- 	local dagger_damage = ability:GetSpecialValueFor("dagger_damage")
-- 	local pDagger = keys.daggers_projectile
-- 	local projectile_speed = ability:GetSpecialValueFor( "projectile_speed" )

-- 	local nearby_enemies = FindUnitsInRadius(team, origin, nil, radius, iTeam, iType, iFlag, iOrder, false)

-- 	-- Create the projectile
-- 	local projectile_info = 
-- 	{
-- 		EffectName = pDagger,
-- 		Ability = ability,
-- 		vSpawnOrigin = caster:GetAbsOrigin(),
-- 		fDistance = radius,
-- 		fStartRadius = radius,
-- 		fEndRadius = radius,
-- 		Source = caster,
-- 		bHasFrontalCone = false,
-- 		iMoveSpeed = projectile_speed,
-- 		bReplaceExisting = false,
-- 		bProvidesVision = true,
-- 		iVisionTeamNumber = caster:GetTeam(),
-- 		iVisionRadius = 200,
-- 		bDrawsOnMinimap = false,
-- 		bVisibleToEnemies = true, 
-- 		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
-- 		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
-- 		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
-- 		fExpireTime = GameRules:GetGameTime() + 1,
-- 	}

-- 	ProjectileManager:CreateLinearProjectile( projectile_info )

-- 	for i, individual_unit in ipairs(nearby_enemies) do  --Restore mana and play a particle effect for every found ally.

-- 		-- The table containing the information needed for ApplyDamage.
-- 		local damage_table =
-- 		{
-- 			victim = individual_unit,
-- 			attacker = caster,
-- 			damage = dagger_damage,
-- 			damage_type = ability:GetAbilityDamageType(),
-- 			damage_flags = DOTA_DAMAGE_FLAG_NONE,
-- 			ability = ability,
-- 		}

-- 		ApplyDamage(damage_table)
-- 	end



-- end

karasu_daggers = class({})

function karasu_daggers:GetAbilityTextureName()
    return "karasu_daggers"
end

function karasu_daggers:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function karasu_daggers:ProcsMagicStick()
    return true
end

function karasu_daggers:OnSpellStart()
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor("radius")

	local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
											 caster:GetAbsOrigin(),
											 nil, 
											 radius, 
											 DOTA_UNIT_TARGET_TEAM_ENEMY, 
											 DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
											 DOTA_UNIT_TARGET_FLAG_NONE, 
											 FIND_ANY_ORDER, 
											 false)

	-- projectile data
	local projectile_name = "particles/units/heroes/kankuro/kankuro_karasu_dagger.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- precache projectile
	local projectile_info = {
		-- Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
	
		bVisibleToEnemies = true,                         -- Optional
		bProvidesVision = false,                           -- Optional
	}

	for k, target in pairs(nearby_enemies) do
		projectile_info.Target = target
		ProjectileManager:CreateTrackingProjectile(projectile_info)
	end
	
end

function karasu_daggers:OnProjectileHit(target, location)
	local damage_table =
	{
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("dagger_damage"),
		damage_type = self:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = self,
	}

	ApplyDamage(damage_table)
end