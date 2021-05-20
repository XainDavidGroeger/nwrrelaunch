

function applyArmorBuffDebuffModifiers ( keys ) 

	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetLevelSpecialValueFor("radius",ability:GetLevel() - 1)
	local duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel() - 1)
	local targets = FindUnitsInRadius(
		keys.caster:GetTeamNumber(), 
		keys.caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local modifier_name_debuff = "modifier_meditation_negative"

	local ability3 = caster:FindAbilityByName("special_bonus_shikamaru_3")
	if ability3 ~= nil then
	    if ability3:IsTrained() then
	    	modifier_name_debuff = "modifier_meditation_negative_special"
	    	duration = duration + 2
	    end
	end

	for _, unit in pairs(targets) do
		ability:ApplyDataDrivenModifier(keys.caster, unit, modifier_name_debuff, {duration = duration})
	end

	local friends = FindUnitsInRadius(
		keys.caster:GetTeamNumber(), 
		keys.caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local modifier_name = "modifier_meditation_positive"

	local ability3 = caster:FindAbilityByName("special_bonus_shikamaru_3")
	if ability3 ~= nil then
	    if ability3:IsTrained() then
	    	modifier_name = "modifier_meditation_positive_special"
	    	duration = duration + 2
	    end
	end

	for _, unit in pairs(friends) do
		ability:ApplyDataDrivenModifier(keys.caster, unit, modifier_name, {duration = duration})
	end

end
