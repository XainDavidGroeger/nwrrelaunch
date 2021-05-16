function playSound( keys )

	if keys.ability:GetName() == "guy_leaf_strong_whirlwind_ult" then 
		keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_END, 3.0)
	else
		keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_END, 1.0)
	end

end

function effectStart( keys )
	local caster = keys.caster
	local particle_caster = ParticleManager:CreateParticle("particles/units/heroes/guy/senpuu_tornado.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster, 3, caster:GetAbsOrigin())

	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2_END)
end

function performAttackOnTarget(keys)

	local ability1 = keys.caster:FindAbilityByName("special_bonus_guy_1")
	if ability1 ~= nil then
	    if ability1:IsTrained() then
	    	
			local damage = keys.caster:GetAverageTrueAttackDamage(nil) / 100 * 35
			ApplyDamage({
				attacker = keys.caster,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = keys.ability,
				victim = keys.target,
				damage = damage,
			})
	    end
	end

	keys.caster:PerformAttack(keys.target, true, true, true, true, false, false, false)

end