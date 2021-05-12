function rasenshuriken_impact(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	local abilityS = keys.caster:FindAbilityByName("special_bonus_naruto_6")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	damage = damage + 320
	    end
	end


	local damage_type = ability:GetAbilityDamageType()
	local target_flags = ability:GetAbilityTargetType()
	
	local aoe = keys.AoE
	local modifier = keys.rs_modifier
	local targetEntities = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

	if( not targetEntities )then
		return
	end
	
	for i,value in pairs(targetEntities) do
	
		ability:ApplyDataDrivenModifier(
			caster,
			value,
			modifier,
			{}
		)
		
		ApplyDamage({attacker = caster, victim = value, ability = ability, damage = damage, damage_type = damage_type})
		
	end

end

function addEffect( keys )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/yondaime/raseng_model.vpcf", PATTACH_POINT_FOLLOW, keys.caster) 
	ParticleManager:SetParticleControlEnt(particle, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_right_hand", keys.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_right_hand", keys.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 3, keys.caster, PATTACH_POINT_FOLLOW, "attach_right_hand", keys.caster:GetAbsOrigin(), true)
 	keys.caster.rasenParticle = particle

end

function removeEffect( keys )
	ParticleManager:DestroyParticle(keys.caster.rasenParticle, true)
end

function CanBeReflected(bool, target, ability)
    if bool == true then
        if target:TriggerSpellReflect(ability) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end


function rasenshuriken_start( keys )
    --[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if keys.target:FindModifierByName("modifier_item_lotus_orb_active") then
        CanBeReflected(true, keys.target, keys.ability)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if keys.target:TriggerSpellAbsorb(keys.ability) then return end
	
	-- Create the projectile
	local info = {
		Target = keys.target,
		Source = keys.caster,
		Ability = keys.ability,
		EffectName = "particles/units/heroes/naruto/rasenshuriken_alt.vpcf",
		bDodgeable = true,
		bProvidesVision = true,
		iMoveSpeed = keys.rs_speed,
        iVisionRadius = keys.vision_radius,
        iVisionTeamNumber = keys.caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION 
	}
	ProjectileManager:CreateTrackingProjectile( info )

end