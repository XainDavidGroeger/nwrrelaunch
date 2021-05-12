function CanBeReflected(bool, target, ability)
    if bool == true then
        if target:TriggerSpellReflect(ability) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function markEnemy( keys )
    local target = keys.target
    local ability = keys.ability
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        CanBeReflected(false, target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(ability) then return end

	local duration = keys.ability:GetLevelSpecialValueFor("duration", (keys.ability:GetLevel() - 1))
	keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_demon_mark",{duration = duration})
	keys.ability.markedEnemy = keys.target
end

function checkDistance( keys )
	local distance = (keys.ability.markedEnemy:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Length2D()

	if distance >= 1500 or not keys.ability.markedEnemy:IsAlive() then
		keys.caster:RemoveModifierByName("modifier_demon_unkillable")
		keys.ability.markedEnemy:RemoveModifierByName("modifier_demon_mark")
	end

end


function registerDamage( keys )

	local target = keys.unit
	local damageTaken = keys.DamageTaken
	if not target.demon_damage then
		target.demon_damage = 0
	end
	keys.caster:SetHealth(keys.caster:GetHealth() + damageTaken)
	
	target.demon_damage = target.demon_damage + damageTaken
	if keys.attacker:IsRealHero() then
		target.lastAttacker = keys.attacker
	end
	if target.lastAttacker == nil then
		target.lastAttacker = keys.attacker
	end 
	
end

function spreadDamage( keys )
	-- Init in case never take any damage
	if not keys.target.demon_damage then
		keys.target.demon_damage = 0
	end

	-- Variables
	local target = keys.target
	local ability = keys.ability
	local minimumHealth = 1
	if (target:GetHealth() - target.demon_damage) < 1 then
		if not target.lastAttacker:IsRealHero() then
			if target.lastAttackerResort ~= nil then
				target:Kill(ability, target.lastAttackerResort)
			else
				target:Kill(ability, target.lastAttacker)
			end
		else
			target:Kill(ability, target.lastAttacker)
		end
		
	else
		target:SetHealth( target:GetHealth() - target.demon_damage )
	end
	target.demon_damage = 0
	target.lastAttackerResort = nil
	target.lastAttacker = nil
end


function registerAttacker( keys )
	if keys.attacker:IsRealHero() then
		keys.caster.lastAttackerResort = keys.attacker
	end
end

function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("zabuza_ult",keys.caster)
	elseif random == 2 then
		EmitSoundOn("zabuza_ult_2",keys.caster)
	end
end