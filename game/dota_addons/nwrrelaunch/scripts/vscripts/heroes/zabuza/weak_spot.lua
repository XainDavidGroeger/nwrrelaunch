--[[
	Author: LearningDave
	Date: 22.10.2015.
	Starts cd for weak spot
]]
function weak_spot( keys )
	if not keys.target:IsBuilding() then
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local caster = keys.caster	
		local modifierName = "modifier_weak_spot"

		keys.ability:EndCooldown()
		local ability5 = caster:FindAbilityByName("special_bonus_zabuza_5")
		if ability5:IsTrained() then
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1) - 1.5)
		else
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
		end

		caster:RemoveModifierByName(modifierName) 
	end	
end

function weak_spot_reset_cd (keys)
	if keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() and not keys.target:IsBuilding() then		
		local new_cd = keys.ability:GetCooldownTimeRemaining() - 1.0
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(new_cd)
	end
end

function addCrit( keys )
	if keys.ability:IsCooldownReady() then 
		local modifierName = "modifier_weak_spot"
		 keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, modifierName, {})
	end
end

