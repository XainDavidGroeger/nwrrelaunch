 --[[Author: LearningDave
	Date: october, 8th 2015.
	Gives vision around the caster
	)]]
function vision( keys )
	local caster = keys.caster	
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local radius = ability:GetLevelSpecialValueFor("vision_aoe", ability_level)

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local ability3 = caster:FindAbilityByName("special_bonus_neji_3")
	if ability3 ~= nil then
	    if ability3:IsTrained() then
	    	duration = duration + 10
	    end
	end

	AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), radius, duration, false)

end
