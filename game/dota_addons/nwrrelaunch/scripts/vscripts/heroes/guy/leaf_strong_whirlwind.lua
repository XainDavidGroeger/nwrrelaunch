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
