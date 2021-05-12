--[[Author: LearningDave
	Date: october, 9th 2015.
	Shoots a wave
]]
function suikodan_no_jutsu( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local forwardVec = (target_point - caster_location):Normalized()

	-- Projectile variables
	local wave_speed = ability:GetLevelSpecialValueFor("wave_speed", (ability:GetLevel() - 1))
	local wave_width = ability:GetLevelSpecialValueFor("wave_aoe", (ability:GetLevel() - 1))
	local wave_range = ability:GetLevelSpecialValueFor("wave_range", (ability:GetLevel() - 1))
	local wave_location = caster_location
	local wave_particle = keys.wave_particle

	-- Creating the projectile
	local projectileTable =
	{
		EffectName = wave_particle,
		Ability = ability,
		vSpawnOrigin = caster_location,
		vVelocity = Vector( forwardVec.x * wave_speed, forwardVec.y * wave_speed, 0 ),
		fDistance = wave_range,
		fStartRadius = wave_width,
		fEndRadius = wave_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	}
	-- Saving the projectile ID so that we can destroy it later
	projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
	
	-- TODO check which targets are hit and apply -armor manually

	-- Timer to provide vision
	Timers:CreateTimer( function()
		-- Calculating the distance traveled
		wave_location = wave_location + forwardVec * (wave_speed * 1/30)

		-- Reveal the area after the projectile passes through it


		local distance = (wave_location - caster_location):Length2D()

		-- Checking if we traveled far enough, if yes then destroy the timer
		if distance >= wave_range then
			return nil
		else
			return 1/30
		end
	end)
end


function suikodan_no_jutsu_apply_damage( keys )

	local ability = keys.ability

	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))

	local ability1 = keys.caster:FindAbilityByName("special_bonus_kisame_1")
	if ability1 ~= nil then
	    if ability1:IsTrained() then
	    	damage = damage + 90
	    end
	end

	local damageTable = {
		victim = keys.target,
		attacker = keys.caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	ApplyDamage( damageTable )

end

function suikodan_no_jutsu_apply_armor_debuff( keys )
	local ability = keys.ability
	local ability5 = keys.caster:FindAbilityByName("special_bonus_kisame_5")
	if ability5 ~= nil then
	    if ability5:IsTrained() then
	    	ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_suikodan_no_jutsu_debuff_armor_special",{})
	    else
	    	ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_suikodan_no_jutsu_debuff_armor",{})
	    end
	end
end