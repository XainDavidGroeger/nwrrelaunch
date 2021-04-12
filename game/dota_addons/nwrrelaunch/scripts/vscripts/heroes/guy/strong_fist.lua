function resetCooldown( keys )
	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1))
end

function resetCooldownOnHit( keys )
	if keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() and not keys.target:IsBuilding() then	
		local ability = keys.caster:FindAbilityByName("guy_strong_fist")
		local ability_ult = keys.caster:FindAbilityByName("guy_strong_fist_ult")

		if ability ~= nil then
			if not ability:IsCooldownReady() then
				local new_cd = ability:GetCooldownTimeRemaining() - 1.0
				ability:EndCooldown()
				ability:StartCooldown(new_cd)
			end
		end	

		if ability_ult ~= nil then 
			if not ability_ult:IsCooldownReady() then
				local new_cd = ability_ult:GetCooldownTimeRemaining() - 1.0
				ability_ult:EndCooldown()
				ability_ult:StartCooldown(new_cd)
			end	
		end		
	end
end