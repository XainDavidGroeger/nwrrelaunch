--[[Author LearningDave
	Date october, 9th 2015
	Swaps caster model
]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	local ability = keys.ability
	local projectile_model = keys.projectile_model

	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	caster.caster_attack = caster:GetAttackCapability()

	-- Sets the new model and projectile

	caster:SetOriginalModel(model)
	caster:SetModelScale(0.65)

	keys.ability.dome = ParticleManager:CreateParticle("particles/units/heroes/kisame/water_dome2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(keys.ability.dome, 0, caster:GetAbsOrigin()) -- Origin
	
end
--[[Author LearningDave
	Date october, 9th 2015
	Reverts back to the original model
]]
function ModelSwapEnd( keys )
	local caster = keys.caster
	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:SetModelScale(1)
	ParticleManager:DestroyParticle( keys.ability.dome, true )
end
--[[
	Author LearningDave
	Date october, 9th 2015.
	Reduces the mana of the caster and swap the model if zero mana is reached
]]
function ManaCost( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local manacost_percentage = keys.ability:GetLevelSpecialValueFor("mana_cost_per_second_percentage", keys.ability:GetLevel() - 1 )
	local max_mana = caster:GetMaxMana()
	local mana_reduce = max_mana / 100 * manacost_percentage / 10
	local current_mana = caster:GetMana()
	local new_mana = current_mana - mana_reduce
	local modifer = keys.modifierRemove
	if (current_mana - mana_reduce) <= 0 then
		caster:SetMana(1)
		caster:SetModel(caster.caster_model)
		caster:SetOriginalModel(caster.caster_model)
		caster:RemoveModifierByName("modifier_kisame_metamorphosis")
		ability:ToggleAbility()
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
	else
		caster:SetMana(new_mana)
	end
end
--[[Author: LearningDave
	Date: 04.11.2015
	Creates a dummy at the target location that acts as the Water prison
]]
function createWaterPrisonDome( keys )
	-- Variables
	keys.caster:Interrupt()
	local caster = keys.caster
	local ability = keys.ability
	local target_point = caster:GetAbsOrigin()

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})
	keys.ability.domeDummy = dummy
	print(dummy:GetAbsOrigin())
	print(caster:GetAbsOrigin())
end
--[[Author: LearningDave
	Date: 04.11.2015
	Makes sure the dummy with the attached water prison effect follows the caster
]]
function domeFollowHero( keys )
	if keys.ability.domeDummy ~= nil and not keys.ability.domeDummy:IsNull() then
		if keys.ability.domeDummy:GetAbsOrigin() ~= keys.caster:GetAbsOrigin() then
			FindClearSpaceForUnit(keys.ability.domeDummy, keys.caster:GetAbsOrigin(), true)
		end
	end
end


function applySlowModifer( keys )

	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetLevelSpecialValueFor("radius",ability:GetLevel() - 1)
	local targets = FindUnitsInRadius(
		keys.target:GetTeamNumber(), 
		keys.caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local ability4 = caster:FindAbilityByName("special_bonus_kisame_4")
	if ability4:IsTrained() then
		for _, unit in pairs(targets) do
			ability:ApplyDataDrivenModifier(keys.caster, unit, "modifer_water_prison_slow_special",{duration = 0.2})
		end
	else
		for _, unit in pairs(targets) do
			ability:ApplyDataDrivenModifier(keys.caster, unit, "modifer_water_prison_slow",{duration = 0.2})
		end
	end
end

function emitCastSound( keys )
	keys.caster:EmitSound("kisame_water_prison_cast")
end

function AddToggleSound( keys )
	keys.togglesound = keys.caster:EmitSound("kisame_water_prison_toggle")
end

function RemoveToggleSound( keys )
	keys.caster:StopSound("kisame_water_prison_toggle")
end