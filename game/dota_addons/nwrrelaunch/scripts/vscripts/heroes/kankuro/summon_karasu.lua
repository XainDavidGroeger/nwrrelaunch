--[[Author: Zenicus
	Date: December 5, 2015
	Creates a puppet that grows in level and has 4 different skills]]
function summon_karasu( keys )

	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin() 
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local hp_gain = ability:GetSpecialValueFor("hp_gain")
	local mana_gain = ability:GetSpecialValueFor("mana_gain")
	local damage_gain = ability:GetSpecialValueFor("damage_gain")

    local kugusta_ability = keys.caster:FindAbilityByName("kankuro_kugusta_no_jutsu")
    local bonus_hp = 0

	if kugusta_ability ~= nil then
		if kugusta_ability:GetLevel() > 0 then
			bonus_hp = kugusta_ability:GetLevelSpecialValueFor("extra_hp", kugusta_ability:GetLevel() - 1)
			local abilityspecial = keys.caster:FindAbilityByName("special_bonus_kankuro_6")
			if abilityspecial ~= nil then
				if abilityspecial:IsTrained() then
					bonus_hp = bonus_hp + 350
				end
			end
		end
	end
    
	-- Ability variables
	local puppet_duration = ability:GetSpecialValueFor("puppet_duration") 

	-- Clear any previous Karasu in case of WTF Mode
	if IsValidEntity(ability.karasu) then 
		ability.karasu:ForceKill(false)
	end

	--Creates the Puppet next to the Caster
	local karasu_unit  = CreateUnitByName("npc_karasu", caster_location + RandomVector(100), true, caster, caster, caster:GetTeamNumber())
	
	--Stores the unit for tracking
	ability.karasu = karasu_unit
	karasu_unit:AddNewModifier(caster, ability, "modifier_phased", {duration = 0.03})

	-- set movement speed
	local karasu_ms = ability:GetLevelSpecialValueFor("ms", ability:GetLevel() - 1)
	local ability3 = keys.caster:FindAbilityByName("special_bonus_kankuro_3")
	if ability3 ~= nil then
		if ability3:IsTrained() then
			karasu_ms = karasu_ms + 50
		end
	end

	karasu_unit:SetBaseMoveSpeed(karasu_ms)

	-- set bonus attack speed
	local karasu_as = ability:GetLevelSpecialValueFor("as_buff", ability:GetLevel() - 1)
	local ability5 = keys.caster:FindAbilityByName("special_bonus_kankuro_5")
	if ability5 ~= nil then
		if ability5:IsTrained() then
			karasu_as = karasu_as + 50
		end
	end


	-- set bonus attack damage
	local ability7 = keys.caster:FindAbilityByName("special_bonus_kankuro_7")
	if ability7 ~= nil then
		if ability7:IsTrained() then
			karasu_unit:SetBaseDamageMin(karasu_unit:GetBaseDamageMin() + 225)
			karasu_unit:SetBaseDamageMax(karasu_unit:GetBaseDamageMax() + 225)
		end
	end
	
	local ability5 = keys.caster:FindAbilityByName("special_bonus_kankuro_5")
	if ability5 ~= nil then
		if ability5:IsTrained() then
			keys.ability:ApplyDataDrivenModifier(
				caster,
				karasu_unit,
				"modifier_karasu_special_bonus_as",
				{}
			)
		end
	end
	

	--Sets the stats gain per level
	karasu_unit:SetHPGain(hp_gain)


	local mp_reg = ability:GetSpecialValueFor("mp_reg")
	local ability1 = keys.caster:FindAbilityByName("special_bonus_kankuro_1")
	if ability1 ~= nil then
		if ability1:IsTrained() then
			mp_reg = mp_reg + 4.0
		end
	end


	local ability4 = keys.caster:FindAbilityByName("special_bonus_kankuro_4")
	if ability4 ~= nil then 
		if ability4:IsTrained() then
			karasu_unit:AddAbility("special_bonus_kankuro_4")
			local abilityUnit4 = karasu_unit:FindAbilityByName("special_bonus_kankuro_4")
			abilityUnit4:SetLevel(1)
		end
	end
	

	karasu_unit:SetBaseManaRegen(mp_reg)

	karasu_unit:SetManaGain(mana_gain)

	karasu_unit:SetDamageGain(damage_gain)

	DebugPrint(bonus_hp)
	DebugPrint(karasu_unit:GetBaseMaxHealth())
	karasu_unit:SetBaseMaxHealth(karasu_unit:GetBaseMaxHealth() + bonus_hp)
	DebugPrint(karasu_unit:GetBaseMaxHealth())

	--Determine Karasu's Skills
	if (ability:GetLevel() == 1) then
		karasu_unit:CreatureLevelUp(1)
		karasu_unit:FindAbilityByName("karasu_daggers"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_poison_gas"):SetLevel(0)
		karasu_unit:FindAbilityByName("karasu_critical_strike"):SetLevel(0)
		karasu_unit:FindAbilityByName("karasu_dismantle_parts"):SetLevel(0)
	elseif (ability:GetLevel() == 2) then
		karasu_unit:CreatureLevelUp(2)
		karasu_unit:FindAbilityByName("karasu_daggers"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_poison_gas"):SetLevel(0)
		karasu_unit:FindAbilityByName("karasu_critical_strike"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_dismantle_parts"):SetLevel(0)
	elseif (ability:GetLevel() == 3) then
		karasu_unit:CreatureLevelUp(3)
		karasu_unit:FindAbilityByName("karasu_daggers"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_poison_gas"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_critical_strike"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_dismantle_parts"):SetLevel(0)
	elseif (ability:GetLevel() == 4) then
		karasu_unit:CreatureLevelUp(4)
		karasu_unit:FindAbilityByName("karasu_daggers"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_poison_gas"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_critical_strike"):SetLevel(1)
		karasu_unit:FindAbilityByName("karasu_dismantle_parts"):SetLevel(1)
	end

	karasu_unit:SetControllableByPlayer(player, true)

	--Kills Puppet after timer
	Timers:CreateTimer(puppet_duration,function()
		if karasu_unit ~= nil and karasu_unit:IsAlive() then
			karasu_unit:ForceKill(false)
		end
	end)
end

