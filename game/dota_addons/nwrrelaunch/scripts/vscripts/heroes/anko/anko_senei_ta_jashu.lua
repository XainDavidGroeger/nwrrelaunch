anko_senei_ta_jashu = class({})

--LinkLuaModifier( "modifier_anko_senei_ta_jashu_ms_slow" , "heroes/anko/modifiers/modifier_anko_senei_ta_jashu_ms_slow.lua" , LUA_MODIFIER_MOTION_NONE )
--[[ ============================================================================================================
	Senei Ta Jashu ability modified from Neji's Internal Bleeding
	Author: Zenicus
	Date: November 17, 2015
	 -- Applies a DOT(damage over time) to the target and popups the damage amount
	 -- Applies Silence as well.
================================================================================================================= ]]
function anko_senei_ta_jashu( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local poison_damage = ability:GetLevelSpecialValueFor("damage_per_tick", (ability:GetLevel() - 1))


	local ms_slow = ability:GetLevelSpecialValueFor("ms_slow",(ability:GetLevel() - 1))


	local damageType = ability:GetAbilityDamageType()
	local damageTable = {
						victim = target,
						attacker = caster,
						damage = poison_damage,
						damage_type = damageType
					}
	ApplyDamage( damageTable )
	PopupDamage(target, poison_damage)

end

function apply_slow_modifier( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local ms_slow_duration = ability:GetLevelSpecialValueFor("slow_duration",(ability:GetLevel() - 1))
	print("slow duration")
	print(ms_slow_duration)

	local abilityS = caster:FindAbilityByName("special_bonus_anko_2")
	if abilityS:IsTrained() then
		ms_slow_duration = ms_slow_duration + 2
	end
	ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_anko_senei_ta_jashu_slow",{duration = ms_slow_duration})

end



