function stopChannelOnDead( keys )
	if keys.caster == nil then
		keys.target:RemoveModifierByName("modifier_bunshin_water_prison_hold")
		--ParticleManager:DestroyParticle(keys.ability.waterPrison_particle, true)
                --ParticleManager:ReleaseParticleIndex(keys.ability.waterPrison_particle)
	end
end

function applyEffect(keys)
    local duration = keys.ability:GetSpecialValueFor("channel_time")
    
    keys.ability.waterPrison_particle = ParticleManager:CreateParticle("particles/units/heroes/kisame/bunshin_prison_new.vpcf", PATTACH_ABSORIGIN, keys.target)
    ParticleManager:SetParticleControl(keys.ability.waterPrison_particle, 0, keys.target:GetAbsOrigin())
    ParticleManager:SetParticleControl(keys.ability.waterPrison_particle, 1, keys.target:GetAbsOrigin())
    ParticleManager:SetParticleControl(keys.ability.waterPrison_particle, 2, Vector(2, 1, 10))
    ParticleManager:SetParticleControl(keys.ability.waterPrison_particle, 3, keys.target:GetAbsOrigin())
	
	Timers:CreateTimer(duration, function ()
	    ParticleManager:DestroyParticle(keys.ability.waterPrison_particle, true)
        ParticleManager:ReleaseParticleIndex(keys.ability.waterPrison_particle)
	end)
end

function emitSoundOnTarget( keys )
	keys.target:EmitSound("kisame_bunshin_water_prison")
end
