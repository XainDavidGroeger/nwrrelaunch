


function applyArmorModifier( keys )

	local ability = keys.ability
	local caster = keys.caster

	local ability3 = keys.caster:FindAbilityByName("special_bonus_sakura_3")
	if ability3 ~= nil then
	    if ability3:IsTrained() then
	    	
	    	ability:ApplyDataDrivenModifier(
	    		caster,
	    		caster,
	    		"modifier_sakura_inner_sakura_special",
	    		{}
	    	)
	    else
        
	    	ability:ApplyDataDrivenModifier(
	    		caster,
	    		caster,
	    		"modifier_sakura_inner_sakura",
	    		{}
	    	)
	    end
    end
end