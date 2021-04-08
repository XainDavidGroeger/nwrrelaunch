function playSound( keys )
	-- body
end

function effectStart( keys )
	local caster = keys.caster
	local particle_caster = ParticleManager:CreateParticle("particles/units/heroes/guy/senpuu_tornado.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster, 3, caster:GetAbsOrigin())
end
