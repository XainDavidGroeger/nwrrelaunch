function Launch(keys)


	local caster = keys.caster
	local ability = keys.ability
	local modifier_name = keys.ModifierName


	local abilityS = caster:FindAbilityByName("special_bonus_guy_2")
	if abilityS:IsTrained() then
		modifier_name = keys.ModifierNameSpecial
	end

	-- apply modifers 
	keys.ability:ApplyDataDrivenModifier(
		keys.caster,
		keys.caster,
		modifier_name,
			{}
		)

end
