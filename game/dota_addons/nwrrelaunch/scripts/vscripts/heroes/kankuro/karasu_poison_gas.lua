--[[
	Author: Zenicus
	Date: 12.8.2015.
	Plays a looping and stops after the duration
]]
function PoisonGasSound( event )
	local target = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

	target:EmitSound("Hero_Alchemist.AcidSpray")

	-- Stops the sound after the duration, a bit early to ensure the thinker still exists
	Timers:CreateTimer(duration-0.1, function() 
		target:StopSound("Hero_Alchemist.AcidSpray") 
	end)

end



function applyDamageInterval ( keys ) 

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel())

	local abilityS = caster:GetOwner():FindAbilityByName("special_bonus_kankuro_4")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	damage = damage + 20
	    end
	end

	ApplyDamage({
		attacker = caster,
		victim = target,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		ability=ability
	})

end

