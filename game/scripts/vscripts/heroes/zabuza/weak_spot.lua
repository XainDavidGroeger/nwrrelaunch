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
	local ability = keys.ability
	if keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() and not keys.target:IsBuilding() then		

		local ability5 = keys.caster:FindAbilityByName("special_bonus_zabuza_5")

		DebugPrint(ability5:IsTrained())

		keys.ability:EndCooldown()
		if ability5:IsTrained() then
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1) - 1.5)
		else
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
		end
	end
end

function addCrit( keys )
	if keys.ability:IsCooldownReady() then 
		local modifierName = "modifier_weak_spot"
		 keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, modifierName, {})
	end
end

