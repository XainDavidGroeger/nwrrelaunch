function SetDamage( event )
	local target = event.target
	local ability = event.ability
	local attack_damage_min = ability:GetLevelSpecialValueFor("damage_min", ability:GetLevel() - 1 )
	local attack_damage_max = ability:GetLevelSpecialValueFor("damage_max", ability:GetLevel() - 1 )

	target:SetBaseDamageMax(attack_damage_max)
	target:SetBaseDamageMin(attack_damage_min)

end


function resetCooldown( keys )

	local ability6 = keys.caster:FindAbilityByName("special_bonus_shikamaru_6")
	if ability6 ~= nil then
	    if ability6:IsTrained() then
	    	keys.ability:EndCooldown()
	    	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 45)
	    end
    end
end