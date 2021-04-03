
function applyDamage( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	local damage = ability:GetLevelSpecialValueFor("aoe_damage", ability:GetLevel() - 1)

	local ability2 = keys.caster:FindAbilityByName("special_bonus_sasuke_2")
	if ability2:IsTrained() then
		damage = damage + 70
	end

		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = ability,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability=ability
		})
end
