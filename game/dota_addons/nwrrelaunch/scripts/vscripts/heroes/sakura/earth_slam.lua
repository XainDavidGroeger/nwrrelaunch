function resetCooldown( keys )
	local ability3 = keys.caster:FindAbilityByName("special_bonus_sakura_2")
	if ability3:IsTrained() then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 3)
	end
end