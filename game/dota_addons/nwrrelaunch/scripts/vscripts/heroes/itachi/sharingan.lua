function sharingan( keys )
	if not keys.target:IsBuilding() and keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() then
		
		local ability    = keys.ability
		local caster    = keys.caster
		local target     = keys.target
		local duration 	 = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1)
		local damage 	 = keys.caster:GetBaseDamageMax()

		caster:EmitSound("itachi_sharingan_proc")
		
		keys.ability:ApplyDataDrivenModifier(keys.caster, target, "modifier_itachi_sharingan_mr_reduce", {duration = duration})
		ApplyDamage({victim = target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		PopupDamage(target, damage)
	end
end
