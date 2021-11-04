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
	if ability1 ~= nil then
	    if ability1:IsTrained() then
	    	duration = duration + 0.25
	    end
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

	local ability1 = keys.caster:FindAbilityByName("special_bonus_neji_5")
	if ability1 ~= nil then
		if ability1:IsTrained() then
			radius = radius + 200
		end
	end

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
	    if unit:GetUnitName() == "npc_dota_tailed_beast_1" or unit:GetUnitName() == "npc_dota_tailed_beast_2" or unit:GetUnitName() == "npc_dota_tailed_beast_3" or unit:GetUnitName() == "npc_dota_tailed_beast_4" or unit:GetUnitName() == "npc_dota_tailed_beast_5" or unit:GetUnitName() == "npc_dota_tailed_beast_6" or unit:GetUnitName() == "npc_dota_tailed_beast_7" or unit:GetUnitName() == "npc_dota_tailed_beast_8" or unit:GetUnitName() == "npc_dota_tailed_beast_9" then return end
		
		    local casterabs = caster:GetAbsOrigin()
		    local unitabs = unit:GetAbsOrigin()
            
		    -- get direction the push back should go
		    local len = ( unitabs - casterabs ):Length2D()
		    len = push_back_length - push_back_length * ( len / push_back_length )
		    
            
		    local knockback = {	center_x = caster:GetAbsOrigin().x,
		    							center_y = caster:GetAbsOrigin().y,
		    							center_z = caster:GetAbsOrigin().z,
		    							duration = 1.0,
		    							knockback_distance = push_back_length,
		    							knockback_height = 0,
		    							knockback_duration = 1.0 * 0.67,	}
		    unit:AddNewModifier(caster, ability, "modifier_knockback", knockback)
			
	end

end

function fireEffect(keys)

	local aoe_target = keys.ability:GetSpecialValueFor("aoe_target")

	local ability1 = keys.caster:FindAbilityByName("special_bonus_neji_5")
	if ability1 ~= nil then
		if ability1:IsTrained() then
			aoe_target = aoe_target + 200
		end
	end

	local pidx = ParticleManager:CreateParticle("particles/units/heroes/neji/neji_kaiten_main.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
    ParticleManager:SetParticleControl(pidx, 1, Vector(aoe_target, 100,100))
end

function dealDamage(keys)


	local aoe_target = keys.ability:GetSpecialValueFor("aoe_target")
	local damage = keys.ability:GetSpecialValueFor("damage")

	local ability1 = keys.caster:FindAbilityByName("special_bonus_neji_5")
	if ability1 ~= nil then
		if ability1:IsTrained() then
			aoe_target = aoe_target + 200
		end
	end

	local full_enemies = FindUnitsInRadius(
		keys.caster:GetTeamNumber(),
		keys.caster:GetAbsOrigin(),
		nil,
		aoe_target,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for key,oneTarget in pairs(full_enemies) do 

		ApplyDamage({
			victim = oneTarget,
			attacker = keys.caster,
			damage = damage,
			damage_type =DAMAGE_TYPE_MAGICAL,
		})

	end

end
