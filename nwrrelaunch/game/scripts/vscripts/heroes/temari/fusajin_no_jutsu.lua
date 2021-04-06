function applyDamage ( keys )

	local ability = keys.ability
	local caster = keys.caster
  
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
  
	local ability1 = caster:FindAbilityByName("special_bonus_temari_1")
	
	if ability1:IsTrained() then
		damage = damage + 75
	end
  
	local damage_table = {
	  victim = keys.target,
	  attacker = keys.caster,
	  damage = damage,
	  damage_type = DAMAGE_TYPE_MAGICAL,		
	  ability = keys.abiltiy
	}
  
	ApplyDamage( damage_table )

end


function resetCooldown( keys )

	local ability2 = keys.caster:FindAbilityByName("special_bonus_temari_2")
	if ability2:IsTrained() then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 2)
	end

end

