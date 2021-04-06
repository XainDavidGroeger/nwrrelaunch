function tsukiyomi( keys )

	local duration = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1)
	local abilityS = keys.caster:FindAbilityByName("special_bonus_itachi_3")
	if abilityS:IsTrained() then
		duration = duration + 1.5
	end

	local ability_damage = keys.ability:GetAbilityDamage()

	if abilityS:IsTrained() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_stun_special", {duration = duration})
	else
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_stun", {duration = duration})
	end

	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = ability_damage, damage_type = DAMAGE_TYPE_MAGICAL})
end


function applySlowModifier ( keys )
	local abilityS = keys.caster:FindAbilityByName("special_bonus_itachi_1")
	if abilityS:IsTrained() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_slow_special", {})
	else
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_slow", {})
	end

end