function CanBeReflected(bool, target, ability)
    if bool == true then
        if target:TriggerSpellReflect(ability) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function applyRaikageKnockupModifier( keys )
	
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local radius = ability:GetLevelSpecialValueFor("target_aoe",ability:GetLevel() - 1)
	local duration = ability:GetLevelSpecialValueFor("armor_reduction_duration",ability:GetLevel() - 1)
	
	local targets = FindUnitsInRadius(
		keys.caster:GetTeamNumber(), 
		keys.target:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local ability4 = caster:FindAbilityByName("special_bonus_raikage_4")
	if ability4 ~= nil then
	    if ability4:IsTrained() then
	    	for _, unit in pairs(targets) do
	    		ability:ApplyDataDrivenModifier(keys.caster, unit, "raikage_knockup_special",{duration = duration})
	    	end
	    else
	    	for _, unit in pairs(targets) do
	    		ability:ApplyDataDrivenModifier(keys.caster, unit, "raikage_knockup",{duration = duration})
	    	end
	    end
	end

end


function startRaikageAnimation (keys)
	keys.caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
end