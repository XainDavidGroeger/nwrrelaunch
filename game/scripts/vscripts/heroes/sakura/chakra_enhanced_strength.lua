function chakra_enhanced_strength( keys )
	if not keys.target:IsBuilding() then
		keys.ability.enemy = keys.target
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, keys.modifier_name, {duration = 1})
	end


end

function chakra_enhanced_strength_apply( keys )

	if keys.caster:HasModifier("modifier_sakura_chakra_enhanced_strength") then
		local ability5 = keys.caster:FindAbilityByName("special_bonus_sakura_5")
		if ability5:IsTrained() then
			keys.caster:RemoveModifierByName("modifier_sakura_chakra_enhanced_strength")
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_sakura_chakra_enhanced_strength_special", {passive = 1})
		end
	end

	if keys.caster:IsRealHero() then

		local vCaster = keys.caster:GetAbsOrigin()
		local vTarget = keys.ability.enemy:GetAbsOrigin()
		local len = ( vTarget - vCaster ):Length2D()
		len = keys.distance - keys.distance * ( len / keys.range )
		local knockbackModifierTable =
		{
			should_stun = 1,
			knockback_duration = keys.duration,
			duration = keys.duration,
			knockback_distance = len,
			knockback_height = 0,
			center_x = keys.caster:GetAbsOrigin().x,
			center_y = keys.caster:GetAbsOrigin().y,
			center_z = keys.caster:GetAbsOrigin().z
		}
		keys.ability.enemy:AddNewModifier( keys.caster, nil, "modifier_knockback", knockbackModifierTable )


		local damage = keys.ability:GetLevelSpecialValueFor("bonus_damage", keys.ability:GetLevel() - 1 )

		local ability1 = keys.caster:FindAbilityByName("special_bonus_sakura_1")
		if ability1:IsTrained() then
			damage = damage + 70
		end

		local damageTable = {}
		damageTable.attacker = keys.caster
		damageTable.victim = keys.target
		damageTable.damage_type = keys.ability:GetAbilityDamageType()
		damageTable.ability = keys.ability
		damageTable.damage = damage
		ApplyDamage(damageTable)


		keys.caster:RemoveModifierByName(keys.modifier_name)

	end
end

function replaceModifer( keys )
	DebugPrint("replace sakura modifier")
	if keys.caster:HasModifier("modifier_sakura_chakra_enhanced_strength") then
		DebugPrint("remove sakura modifier")
		keys.caster:RemoveModifierByName("modifier_sakura_chakra_enhanced_strength")
		DebugPrint("remove sakura modifier")
		keys.caster:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_sakura_chakra_enhanced_strength_special", {passive = 1})
	end

end