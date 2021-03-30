--[[
	Author: LearningDave
	Date: October, 27th 2015
	Does apply the max ms to the caster for a given duration
]]
function gainMaxMoveSpeed( keys )
	local caster = keys.caster
	local ability = keys.ability

	local duration =  ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	local abilityS = keys.caster:FindAbilityByName("special_bonus_sakura_4")
	if abilityS:IsTrained() then
		duration = duration + 4
	end

	local speed = caster:GetIdealSpeed()
	--TODO get max ms value dynamicly
	caster:SetBaseMoveSpeed(1000)

	Timers:CreateTimer( duration, function()
        caster:SetBaseMoveSpeed(speed)
		return nil
	end
	)

end