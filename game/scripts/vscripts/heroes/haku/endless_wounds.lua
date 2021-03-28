function applyStacksAttack( keys )
	if keys.target:IsAlive() then		
		local stacks_per_attack = keys.ability:GetLevelSpecialValueFor("stacks_per_attack", keys.ability:GetLevel() - 1 )
		local threshold = keys.ability:GetLevelSpecialValueFor("threshold", keys.ability:GetLevel() - 1 )
		local duration = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1 )
		if keys.target:HasModifier("modifier_haku_endless_needles_victim") then
			local modifier_victim = keys.target:FindModifierByName("modifier_haku_endless_needles_victim")
			local stacks = keys.target:GetModifierStackCount(modifier_victim:GetName(),keys.ability)
			if (stacks + stacks_per_attack) < threshold then
				keys.target:SetModifierStackCount(modifier_victim:GetName(),keys.ability,stacks + stacks_per_attack)
			else
				keys.target:SetModifierStackCount(modifier_victim:GetName(),keys.ability,threshold)
			end
		else
			keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_haku_endless_needles_victim",{})
			local modifier_victim = keys.target:FindModifierByName("modifier_haku_endless_needles_victim")
			keys.target:SetModifierStackCount(modifier_victim:GetName(),keys.ability,stacks_per_attack)
		end	
		Timers:CreateTimer( duration, function()
			if  keys.target:HasModifier("modifier_haku_endless_needles_victim") then
			local modifier_victim = keys.target:FindModifierByName("modifier_haku_endless_needles_victim")
			local stacks = keys.target:GetModifierStackCount(modifier_victim:GetName(),keys.ability)
				if (stacks - stacks_per_attack) > 0 then		
		        	keys.target:SetModifierStackCount(modifier_victim:GetName(),keys.ability,stacks - stacks_per_attack)
				else
					keys.target:RemoveModifierByName("modifier_haku_endless_needles_victim")
				end
		    end
		return nil
		end
		)
	end
end


function applyModifierFromAbility( keys )	
	local endless_wounds_stacks = keys.ability:GetLevelSpecialValueFor("endless_wounds_stacks", keys.ability:GetLevel() - 1 )
	local endless_wounds_ability = keys.caster:FindAbilityByName("haku_endless_wounds")
	if endless_wounds_ability:GetLevel() > 0 then
		local endless_wounds_threshold = endless_wounds_ability:GetLevelSpecialValueFor("threshold", endless_wounds_ability:GetLevel() - 1 )
		local endless_wounds_duration = endless_wounds_ability:GetLevelSpecialValueFor("duration", endless_wounds_ability:GetLevel() - 1 )

		if keys.target:HasModifier("modifier_haku_endless_needles_victim") then
		local modifier_victim = keys.target:FindModifierByName("modifier_haku_endless_needles_victim")
			local stacks = keys.target:GetModifierStackCount(modifier_victim:GetName(),keys.ability)
			if (stacks + endless_wounds_stacks) < endless_wounds_threshold then
				keys.target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,stacks + endless_wounds_stacks)
			else
				keys.target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,endless_wounds_threshold)
			end
		else
			endless_wounds_ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_haku_endless_needles_victim",{})
			local modifier_victim = keys.target:FindModifierByName("modifier_haku_endless_needles_victim")
			keys.target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,endless_wounds_stacks)
		end	
		Timers:CreateTimer( endless_wounds_duration, function()
			if  keys.target:HasModifier("modifier_haku_endless_needles_victim") then
			local modifier_victim = keys.target:FindModifierByName("modifier_haku_endless_needles_victim")
			local stacks = keys.target:GetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability)
				if (stacks - endless_wounds_stacks) > 0 then		
		        	keys.target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,stacks - endless_wounds_stacks)
				else
					keys.target:RemoveModifierByName("modifier_haku_endless_needles_victim")
				end
		    end
		return nil
		end
		)
	end
end

function applyEffect( keys )

end