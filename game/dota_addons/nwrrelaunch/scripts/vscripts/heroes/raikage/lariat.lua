require('items')

--[[
	Author: Mognakor
	Date: December, 5/6th 2015.
]]
function add_physics(caster)
	Physics:Unit(caster)
	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)	
end

function remove_physics(caster)
	caster:SetPhysicsAcceleration(Vector(0,0,0))
	caster:SetPhysicsVelocity(Vector(0,0,0))
	caster:OnPhysicsFrame(nil)
	caster:PreventDI(false)
	--caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
	caster:SetAutoUnstuck(true)
	caster:FollowNavMesh(true)

	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)

end

function LariatHit(keys,target)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	ParticleManager:DestroyParticle(keys.pfx, false)
	caster:RemoveModifierByName("modifier_lariat_energy_shield")

	caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_3)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3_END, 2)

	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local abilityS = keys.caster:FindAbilityByName("special_bonus_raikage_3")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	damage = damage + 220
	    end
	end

	ability:ApplyDataDrivenModifier(
			caster,
			target,
			"modifier_lariat_stun",
			{}
		)
		
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})



	local particle_impact = keys.particle_impact
	
	-- Fire impact particle
	local enemy_loc = target:GetAbsOrigin()
	local impact_pfx = ParticleManager:CreateParticle(particle_impact, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(impact_pfx, 0, enemy_loc)
	ParticleManager:SetParticleControlEnt(impact_pfx, 3, target, PATTACH_ABSORIGIN, "attach_origin", enemy_loc, true)

end

function LariatPeriodic(gameEntity, keys)
	local l_keys = keys.keys
	local caster = l_keys.caster
	local ability = l_keys.ability

	local ability_level = ability:GetLevel() - 1

	local caster = l_keys.caster
	local velocity = ability:GetLevelSpecialValueFor("speed", ability_level)

	local vector = keys.point - caster:GetAbsOrigin()
	local direction = vector:Normalized()

	GridNav:DestroyTreesAroundPoint( caster:GetAbsOrigin(), 60, true)
	caster:SetPhysicsVelocity(direction * velocity)
	
	local targetEntities = FindUnitsInRadius(caster:GetOpposingTeamNumber(), caster:GetAbsOrigin(), nil,
		3*caster:GetPaddedCollisionRadius(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	
	local target = targetEntities[1]
	if(target) then	
		LariatHit(l_keys,target)
		
		remove_physics(caster)
		return nil
	end

	-- If the target reached the ground then remove physics
	if vector:Length2D() <= caster:GetPaddedCollisionRadius() then
		if( keys.origin ~= nil) then
			local timer_tbl =
			{
				callback = LariatPeriodic,
				keys = l_keys,
				point = keys.origin
			}
			Timers:CreateTimer(timer_tbl)
		else
			remove_physics(caster)
			caster:RemoveModifierByName("modifier_lariat_energy_shield")
			ParticleManager:DestroyParticle(l_keys.pfx, false)
		end
	
		return nil
	end

	return 0.03
end

function Lariat(keys)	
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local velocity = ability:GetLevelSpecialValueFor("speed", ability_level)
	local sound_impact = "Hero_Sven.StormBoltImpact"
	local particle_impact = "particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf"

	caster:FadeGesture(ACT_DOTA_IDLE)
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

	keys.pfx = ParticleManager:CreateParticle("particles/units/heroes/raikage/lariat_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(keys.pfx, 0, Vector(1, 0, 0))

	add_physics(caster)
	
	local timer_tbl =
		{
			callback = LariatPeriodic,
			keys = keys,
			point = point,
			origin = caster:GetAbsOrigin()
		}
	
	--Movement
	Timers:CreateTimer(timer_tbl)
end

function fireGroundEffect( keys )

	local target_point = keys.target_points[1]
	local caster = keys.caster


	local origin = caster:GetAbsOrigin()
	local between = origin:Lerp(target_point, 0.5)


	local ground = ParticleManager:CreateParticle("particles/units/heroes/raikage/lariat_ground_parent.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ground, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ground, 1, between)
	ParticleManager:SetParticleControl(ground, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ground, 3, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ground, 4, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(ground, 5, target_point)
	ParticleManager:SetParticleControl(ground, 6, between)


end