LinkLuaModifier("modifier_chronosphere_speed_lua", "heroes/hero_faceless_void/modifiers/modifier_chronosphere_speed_lua.lua", LUA_MODIFIER_MOTION_NONE)


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


function applyInvis( keys )
	local duration = keys.ability:GetLevelSpecialValueFor("duration", (keys.ability:GetLevel() - 1))
	if not keys.caster:HasModifier("modifier_zabuza_kirigakure_no_jutsu_ms_buff") then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_zabuza_kirigakure_no_jutsu_ms_buff",{duration = duration})
	end
end


function spin_web( keys )

	local caster = keys.caster

		-- Variables
		local target = keys.target_points[1]
		local ability = keys.ability
		local player = caster:GetPlayerID()

		-- Modifiers and dummy abilities/modifiers
		local stack_modifier = keys.stack_modifier
		local dummy_modifier = keys.dummy_modifier

		-- AbilitySpecial variables
		local maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
		local duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_restore_time", ( ability:GetLevel() - 1 ) )

		-- Dummy
		local dummy = CreateUnitByName("npc_dummy_unit", target, false, caster, caster, caster:GetTeam())
		ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})
		dummy:SetControllableByPlayer(player, true)
		


		-- Timer to remove the dummy
		Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end


function spin_web_aura( keys )
	local ability = keys.ability
	local caster = keys.caster	
	local target = keys.target

	-- Owner variables
	local caster_owner = caster:GetPlayerOwner()
	local target_owner = target:GetPlayerOwner()

	-- Units
	local unit_spiderling = keys.unit_spiderling
	local unit_spiderite = keys.unit_spiderite
	local all_units = ability:GetLevelSpecialValueFor("all_units", (ability:GetLevel() - 1))

	-- Modifiers
	local aura_modifier = keys.aura_modifier
	local pathing_modifier = keys.pathing_modifier
	local pathing_fade_modifier = keys.pathing_fade_modifier
	local invis_modifier = keys.invis_modifier
	local invis_fade_modifier = keys.invis_fade_modifier

	local fade_delay = ability:GetLevelSpecialValueFor( "fade_delay", ( ability:GetLevel() - 1 ) )


	if keys.target:IsRealHero() then


		ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {})

				-- If it doesnt have the fade pathing modifier or the pathing modifier then apply it
		if not target:HasModifier(pathing_fade_modifier) and not target:HasModifier(pathing_modifier) then
			ability:ApplyDataDrivenModifier(caster, target, pathing_modifier, {}) 
		end

		-- If it doesnt have the fade invis modifier or the invis modifier then apply it
		if not target:HasModifier(invis_modifier) and not target:HasModifier(invis_fade_modifier) then
			ability:ApplyDataDrivenModifier(caster, target, invis_fade_modifier, {duration = fade_delay})
		end

		local ability5 = keys.caster:FindAbilityByName("special_bonus_zabuza_5")
		if ability5:IsTrained() then
			if not target:HasModifier("modifier_special_bonus_attack_damage") then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_special_bonus_attack_damage", {})
			end
		end

	end
end

function appylMsBoost( keys )
	local ability = keys.ability
	local caster = keys.caster	
	local target = keys.target

	-- Owner variables
	local caster_owner = caster:GetPlayerOwner()
	local target_owner = target:GetPlayerOwner()
	
	if caster_owner == target_owner then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, keys.ms_modifier, {})
	end
end

function applyInvisModifier( keys )
	local ability = keys.ability
	local fade_delay = ability:GetLevelSpecialValueFor( "fade_delay", ( ability:GetLevel() - 1 ) )

	local target = nil

	if keys.makeinvis == 'ATTACKER' then
		target = keys.attacker
	end

	if keys.makeinvis == 'UNIT' then
		target = keys.unit
	end

	local ability1 = keys.caster:FindAbilityByName("special_bonus_zabuza_4")
	if ability1:IsTrained() then
		fade_delay = fade_delay - 0.8
	end

	keys.ability:ApplyDataDrivenModifier(keys.caster, target, "modifier_web_invis_fade_datadriven", {duration = fade_delay})
end


function applyDamageModifier( keys )
	local ability = keys.ability
	local fade_delay = ability:GetLevelSpecialValueFor( "fade_delay", ( ability:GetLevel() - 1 ) )

	local target = nil

	if keys.makeinvis == 'ATTACKER' then
		target = keys.attacker
	end

	if keys.makeinvis == 'UNIT' then
		target = keys.unit
	end

	local ability5 = keys.caster:FindAbilityByName("special_bonus_zabuza_5")
	if ability5:IsTrained() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, target, "modifier_special_bonus_attack_damage", {duration = fade_delay})
	end

end

function playSoundOnPlayer ( keys )
	EmitSoundOnEntityForPlayer("zabuza_mist_talking", keys.caster, keys.caster:GetPlayerOwnerID())
end