function CanBeReflected(bool, target, ability)
	if bool == true then
        if target:TriggerSpellReflect(ability) then return end
	else
	    --[[ simulate the cancellation of the ability if it is not reflected ]]
	    ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
		EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
	end
end

function tsukiyomi( keys )
	local duration = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1)
	local abilityS = keys.caster:FindAbilityByName("special_bonus_itachi_3")
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if keys.target:FindModifierByName("modifier_item_lotus_orb_active") then
        CanBeReflected(false, keys.target, keys.ability) --change to "true" when the ability becomes lua
		
        return
    end
	
	--[[ if the target has Linken's Sphere, cancels the use of the ability ]]
	if keys.target:TriggerSpellAbsorb(keys.ability) then return end
	
	if abilityS:IsTrained() then
		duration = duration + 1.5
	end

	local ability_damage = keys.ability:GetAbilityDamage()
    
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_stun_special", {duration = duration})
	    else
	    	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_stun", {duration = duration})
	    end
	end

	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = ability_damage, damage_type = DAMAGE_TYPE_MAGICAL})
end


function applySlowModifier ( keys )
	local abilityS = keys.caster:FindAbilityByName("special_bonus_itachi_1")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_slow_special", {})
	    else
	    	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_itachi_tsukiyomi_slow", {})
	    end
    end
end