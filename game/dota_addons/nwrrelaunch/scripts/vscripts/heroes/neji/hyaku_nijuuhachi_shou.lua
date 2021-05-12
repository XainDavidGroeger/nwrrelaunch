--[[Author: LearningDave
	Date: October, 9th 2015
	Reveals the target if its invisible]]
function hyaku_nijuuhachi_shou_invis_check( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	keys.ability.target = target
	if target:IsInvisible() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {})
	end
end

function createParticle( keys )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/bagum_projected.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControl(particle, 0, keys.caster:GetAbsOrigin()) -- Origin
	keys.ability.ultiParticle = particle
end

function removeParticle( keys )
	ParticleManager:DestroyParticle( keys.ability.ultiParticle, true )
end

function silenceTarget( keys )
	local abilityS = keys.caster:FindAbilityByName("special_bonus_neji_4")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.ability.target, "modifier_hyaku_nijuuhachi_shou_special_silence", {duration = 5})
	    end
	end
end

function removeModifiers( keys )
	keys.caster:RemoveModifierByName("modifier_hyaku_nijuuhachi_shou_caster")
	keys.ability.target:RemoveModifierByName("modifier_hyaku_nijuuhachi_shou")
	keys.ability.target:RemoveModifierByName("modifier_fiend_grip_invis_datadriven")
end

function cancelSpell ( keys )
	print("testcancel")
	keys.caster:StopSound( "neji_64_channel" )
	keys.caster:StopSound( "neji_64_cast_talking" )
	if keys.ability.images_particle ~= nil then
		ParticleManager:DestroyParticle(keys.ability.images_particle, false)
	end
	if keys.number_32 ~= nil then
		ParticleManager:DestroyParticle(keys.number_32, false)
	end
	if keys.number_64 ~= nil then
		ParticleManager:DestroyParticle(keys.number_64, false)
	end
	if keys.number_128 ~= nil then
		ParticleManager:DestroyParticle(keys.number_128, false)
	end
	
end

function addParticle( keys )
	
	local caster = keys.caster
	local target = keys.target

	local distance = target:GetAbsOrigin() - caster:GetAbsOrigin()

		
	keys.ability.images_particle = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/2_ulti_images.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(keys.ability.images_particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(keys.ability.images_particle, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(keys.ability.images_particle, 3, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(keys.ability.images_particle, 4, caster:GetForwardVector() * distance:Length2D() )



	Timers:CreateTimer(1.33, function()
		keys.number_32 = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/numbers_32.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(keys.number_32, 1, Vector(0, 1, 0))
		ParticleManager:SetParticleControl(keys.number_32, 2, Vector(0, 6, 0))

		Timers:CreateTimer(1.33, function()
			ParticleManager:DestroyParticle(keys.number_32, false)
			keys.number_64 = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/numbers_64.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
			ParticleManager:SetParticleControl(keys.number_64, 1, Vector(0, 3, 0))
			ParticleManager:SetParticleControl(keys.number_64, 2, Vector(0, 2, 0))
	
			Timers:CreateTimer(1.33, function()
				ParticleManager:DestroyParticle(keys.number_64, false)
				keys.number_128 = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/numbers_128.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
				ParticleManager:SetParticleControl(keys.number_128, 1, Vector(0, 6, 0))
				ParticleManager:SetParticleControl(keys.number_128, 2, Vector(0, 4, 0))
				--ParticleManager:SetParticleControl(keys.number_128, 3, Vector(0, 8, 0))
			end)
		end)
	end)

	Timers:CreateTimer(5.0, function()
		ParticleManager:DestroyParticle(keys.number_32, false)
		ParticleManager:DestroyParticle(keys.number_64, false)
		ParticleManager:DestroyParticle(keys.number_128, false)
	end)
	


	--ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin() + caster:GetForwardVector() * Vector(1,1,1) , true)

end


function applySilence(keys)

	keys.target:EmitSound("neji_64_finish_sound")

	local silence_duration = keys.ability:GetSpecialValueFor("silence_duration")

	local abilityS = keys.caster:FindAbilityByName("special_bonus_neji_4")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	silence_duration = silence_duration + 5
	    end
	end

	keys.ability:ApplyDataDrivenModifier(
		keys.caster,
		keys.target,
		"modifier_hyaku_nijuuhachi_shou_silence",
		{
			duration = silence_duration
		}
	)
end
