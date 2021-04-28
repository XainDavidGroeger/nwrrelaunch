--[[ ============================================================================================================
	Anko's Sojasosai No Jutsu
	Author: Zenicus
	Date: November 19, 2015
	 -- Applies damage based on target's missing HP to target and self
	- Converted from datadriven to lua by EarthSalamander
	- Date: 27.04.2021
================================================================================================================= ]]

LinkLuaModifier("modifier_anko_senei_ta_jashu_poison", "scripts/vscripts/heroes/anko/anko_senei_ta_jashu.lua", LUA_MODIFIER_MOTION_NONE)

anko_sojasosai_no_jutsu = anko_sojasosai_no_jutsu or class({})

function anko_sojasosai_no_jutsu:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage_percent = self:GetSpecialValueFor("damage_percent")
	local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
	local final_damage = target_missing_hp * damage_percent / 100
	local damageType = self:GetAbilityDamageType()

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = final_damage,
		damage_type = damageType,
	})

	ApplyDamage({
		victim = caster,
		attacker = caster,
		damage = final_damage,
		damage_type = damageType,
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
	})

	self:GetCaster():EmitSound("anko_sacrifice_cast")
end
