LinkLuaModifier("modifier_chronosphere_speed_lua", "heroes/hero_faceless_void/modifiers/modifier_chronosphere_speed_lua.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: LearningDave
	Date: 22.10.2015
	Creates a dummy at the target location that acts as the Fog
	]]
function Chronosphere( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]

	-- Special Variables
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})


	-- Timer to remove the dummy
	Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end


function applySmokeModifier( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	local duration = 1


	local modifier_name = "modifier_zabuza_kirigakure_no_jutsu_silence"


	local ability2 = caster:FindAbilityByName("special_bonus_zabuza_2")
	if ability2 ~= nil then
		if ability2:IsTrained() then
			modifier_name = "modifier_zabuza_kirigakure_no_jutsu_silence_special"
		end
	end
	

	keys.ability:ApplyDataDrivenModifier(caster,target,modifier_name, 
		{
			duration = duration
		}
	)
end

function applySmokeModifierNew( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)


	local ability4 = caster:FindAbilityByName("special_bonus_zabuza_4")
	if ability4 ~= nil then
		if ability4:IsTrained() then
			radius = radius + 175
		end
	end
	

	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		target:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local duration = 1


	local modifier_name = "modifier_zabuza_kirigakure_no_jutsu_silence"

	local ability2 = caster:FindAbilityByName("special_bonus_zabuza_2")
	if ability2 ~= nil then
		if ability2:IsTrained() then
			modifier_name = "modifier_zabuza_kirigakure_no_jutsu_silence_special"
		end
	end
	

	for _, unit in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster,unit,modifier_name, 
			{
				duration = duration
			}
		)
	end
	
end


function attachEffect( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	local ability4 = caster:FindAbilityByName("special_bonus_zabuza_4")
	if ability4 ~= nil then
		if ability4:IsTrained() then
			radius = radius + 175
		end
	end
	

	local smoke_particle = "particles/units/heroes/hero_riki/riki_smokebomb.vpcf"
	local particle = ParticleManager:CreateParticle(smoke_particle, PATTACH_WORLDORIGIN, keys.target)
	ParticleManager:SetParticleControl(particle, 0, keys.target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, radius))

	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(particle, false)
		ParticleManager:ReleaseParticleIndex(particle)
	end)

end


