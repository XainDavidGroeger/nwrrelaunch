function createParticle( keys )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/neji/neji_forgot_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControl(particle, 1, keys.caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControlEnt(particle, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), true)
	keys.ability.ultiParticle = particle
end

function removeParticle( keys )
	keys.caster:Stop()
	ParticleManager:DestroyParticle( keys.ability.ultiParticle, true )
end

function applyStun( keys ) 

	local ability = keys.ability
	local caster = keys.caster

	local radius = ability:GetLevelSpecialValueFor("aoe_target", ability:GetLevel() - 1)

	local duration = ability:GetLevelSpecialValueFor("stun_duration",ability:GetLevel() - 1)

	local ability1 = caster:FindAbilityByName("special_bonus_neji_1")
	if ability1:IsTrained() then
		duration = duration + 0.25
	end

	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	for _, unit in pairs(targets) do
		unit:AddNewModifier(unit, ability, "modifier_stunned", {duration = duration})
	end

end


function knockBack( keys )

	local ability = keys.ability
	local caster = keys.caster

	local radius = ability:GetLevelSpecialValueFor("aoe_target", ability:GetLevel() - 1)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel() - 1)
	local push_back_length = ability:GetLevelSpecialValueFor("push_back_length",ability:GetLevel() - 1)


	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	for _, unit in pairs(targets) do

		local knockback = {	center_x = unit.x,
									center_y = unit.y,
									center_z = unit.z,
									duration = 1.0,
									knockback_distance = push_back_length,
									knockback_height = 0,
									knockback_duration = 1.0 * 0.67,	}
		unit:AddNewModifier(caster, ability, "modifier_knockback", knockback)

	end

end
