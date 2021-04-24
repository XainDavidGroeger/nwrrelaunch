--[[Author: LearningDave
	Date: 04.11.2015
	Applies damage to target and fires a impact effect after x sec delay
]]
function applyDamage( keys )
	local delay_to_damage = keys.ability:GetLevelSpecialValueFor("delay_to_dmg",  keys.ability:GetLevel() - 1)
	Timers:CreateTimer( delay_to_damage, function()
		if keys.target:HasModifier("modifier_gaara_sabaku_kyuu") then
			local abilityDamageType = keys.ability:GetAbilityDamageType()

			local ability = keys.ability

			keys.target:EmitSound("gaara_prison_impact")

			local damage = ability:GetLevelSpecialValueFor("dmg", ability:GetLevel() - 1 )
			local abilityS = keys.caster:FindAbilityByName("special_bonus_gaara_4")
			if abilityS:IsTrained() then
				damage = damage + 380
			end

			PopupDamage(keys.target, damage)
			local damageTable = {
						victim = keys.target,
						attacker = keys.caster,
						damage = damage,
						damage_type = abilityDamageType
					}
			ApplyDamage( damageTable )

			local particle_impact = keys.particle_impact
			local enemy_loc = keys.target:GetAbsOrigin()
			local enemy = keys.target
			local impact_pfx = ParticleManager:CreateParticle(particle_impact, PATTACH_ABSORIGIN, enemy)
			ParticleManager:SetParticleControl(impact_pfx, 0, enemy_loc)
			ParticleManager:SetParticleControlEnt(impact_pfx, 3, enemy, PATTACH_ABSORIGIN, "attach_origin", enemy_loc, true)
		end 
	end
	)
	
end


function fireSound(keys)
	keys.caster:EmitSound("gaara_prison_talking")
	keys.caster:EmitSound("gaara_prison_cast")
end
