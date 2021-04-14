--[[
	Author: Noya
	Date: 25.01.2015.
	Creates a dummy unit to apply the Blizzard thinker modifier which does the waves
]]

function BlizzardStartPoint( event )
	local caster = event.caster
	local point = event.target_points[1]

	caster.blizzard_dummy_point = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())

	local abilityS = caster:FindAbilityByName("special_bonus_haku_4")
	if abilityS ~= nil then
		if abilityS:IsTrained() then
			event.ability:ApplyDataDrivenModifier(caster, caster.blizzard_dummy_point, "modifier_blizzard_wave_special", nil)	
		else 
			event.ability:ApplyDataDrivenModifier(caster, caster.blizzard_dummy_point, "modifier_blizzard_wave", nil)		
		end
	else
		event.ability:ApplyDataDrivenModifier(caster, caster.blizzard_dummy_point, "modifier_blizzard_wave", nil)
	end


end


--[[function BlizzardWaveStart( event )
	local caster = event.caster
	event.ability:ApplyDataDrivenModifier(caster, caster.blizzard_dummy_point, "modifier_blizzard_thinker", nil)
end]]

-- -- Create the particles with small delays between each other
function BlizzardWave( event )
	local caster = event.caster

	local target_position = event.target:GetAbsOrigin() --event.target_points[1]
    local particleName = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
    local distance = 100

    -- Center explosion
    local particle1 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle1, 0, target_position )

	local fv = caster:GetForwardVector()
    local distance = 100

    Timers:CreateTimer(0.05,function()
    local particle2 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle2, 0, target_position+RandomVector(100) ) end)

    Timers:CreateTimer(0.1,function()
	local particle3 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle3, 0, target_position-RandomVector(100) ) end)

    Timers:CreateTimer(0.15,function()
	local particle4 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle4, 0, target_position+RandomVector(RandomInt(50,100)) ) end)

    Timers:CreateTimer(0.2,function()
	local particle5 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle5, 0, target_position-RandomVector(RandomInt(50,100)) ) end)
end

function BlizzardEnd( event )
	local caster = event.caster

	local abilityS = caster:FindAbilityByName("special_bonus_haku_4")
	if abilityS ~= nil then
		if abilityS:IsTrained() then
			caster.blizzard_dummy_point:RemoveModifierByName("modifier_blizzard_wave_special")
		else 
			caster.blizzard_dummy_point:RemoveModifierByName("modifier_blizzard_wave")	
		end
	else
		caster.blizzard_dummy_point:RemoveModifierByName("modifier_blizzard_wave")	
	end
	
	
	caster:RemoveModifierByName("modifier_blizzard_channelling")

	local blizzard_dummy_point_pointer = caster.blizzard_dummy_point
	Timers:CreateTimer(0.4,function() blizzard_dummy_point_pointer:RemoveSelf() end)
end

function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("haku_needles",keys.caster)
	elseif random == 2 then
		EmitSoundOn("haku_needles_2",keys.caster)
	end
end


function applyEndlessWounds( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = caster:FindAbilityByName("haku_needles")

	if caster:FindAbilityByName("haku_endless_wounds"):GetLevel() > 0 then 

		local endless_wounds = caster:FindAbilityByName("haku_endless_wounds")

		local threshold = endless_wounds:GetSpecialValueFor("threshold")
		local duration = endless_wounds:GetSpecialValueFor("duration")
		local endless_wounds_stacks = ability:GetSpecialValueFor("endless_wounds_stacks")

		local stack_modifier = "modifier_haku_endless_needles_victim"

		if target:HasModifier(stack_modifier) then
			local stacks = target:GetModifierStackCount(stack_modifier, endless_wounds)
			if (stacks + endless_wounds_stacks) <= threshold then
				target:SetModifierStackCount(stack_modifier,endless_wounds, stacks + endless_wounds_stacks)
			else
				target:SetModifierStackCount(stack_modifier,endless_wounds, threshold)
			end
		else 
			modifier_debuff = target:AddNewModifier(caster, endless_wounds, stack_modifier, {duration = duration})
			target:SetModifierStackCount(stack_modifier, endless_wounds, endless_wounds_stacks)
		end

	end


end