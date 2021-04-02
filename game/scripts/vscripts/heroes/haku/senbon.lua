function resetCooldown( keys )
	local abilityS2 = keys.caster:FindAbilityByName("special_bonus_haku_2")
	if abilityS2:IsTrained() then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 2)
	end


	

end
