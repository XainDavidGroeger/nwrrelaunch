function execute( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local target_hp_percent = target:GetHealth() / (target:GetMaxHealth() / 100) 

	local health_threshold = ability:GetLevelSpecialValueFor( "health_threshold", ( ability:GetLevel() - 1 ) )

	local ability3 = keys.caster:FindAbilityByName("special_bonus_zabuza_3")
	if ability3 ~= nil then
	    if ability3:IsTrained() then
	    	health_threshold = health_threshold + 7
	    end
	end

	if target_hp_percent <= health_threshold then
		if not target:IsBuilding() and keys.caster:GetTeamNumber() ~= keys.target:GetTeamNumber() then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_executioners_blade_crit", {duration = 0.3})
		end
	end
end

function resetCooldown ( keys )
	local ability2 = keys.caster:FindAbilityByName("special_bonus_zabuza_2")
	if ability2 ~= nil then
	    if ability2:IsTrained() then
	    	keys.ability:EndCooldown()
	    	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 2)
	    end
	end
end