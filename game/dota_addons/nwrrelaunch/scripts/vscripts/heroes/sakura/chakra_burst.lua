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
	if abilityS ~= nil then
		if abilityS:IsTrained() then
			duration = duration + 4
		end
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

function applyBurstModifier( keys )

	local duration = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1)
	local ability4 = keys.caster:FindAbilityByName("special_bonus_sakura_4")
	if ability4 ~= nil then
		if ability4:IsTrained() then
			duration = duration + 4
		end
	end

	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_sakura_chakra_burst", {duration = duration})
end