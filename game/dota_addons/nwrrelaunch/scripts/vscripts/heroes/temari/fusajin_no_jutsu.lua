function CanBeReflected(bool, target, ability)
    if bool == true then
        if target:TriggerSpellReflect(ability) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function applyDamage ( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        CanBeReflected(false, target, ability)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(ability) then return end
  
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
  
	local ability1 = caster:FindAbilityByName("special_bonus_temari_1")
	
	if ability1 ~= nil then
	    if ability1:IsTrained() then
	    	damage = damage + 75
	    end
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
	if ability2 ~= nil then
	    if ability2:IsTrained() then
	    	keys.ability:EndCooldown()
	    	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 2)
	    end
    end
end

