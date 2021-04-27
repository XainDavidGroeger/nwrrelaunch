--[[ ============================================================================================================
	Senei Ta Jashu ability modified from Neji's Internal Bleeding
	Author: Zenicus
	Date: November 17, 2015
	 -- Applies a DOT(damage over time) to the target and popups the damage amount
	 -- Applies Silence as well.
	- Converted from datadriven to lua by EarthSalamander
	- Date: 27.04.2021
================================================================================================================= ]]

LinkLuaModifier("modifier_anko_senei_ta_jashu_poison", "scripts/vscripts/heroes/anko/anko_senei_ta_jashu.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anko_senei_ta_jashu_slow", "scripts/vscripts/heroes/anko/anko_senei_ta_jashu.lua", LUA_MODIFIER_MOTION_NONE)

anko_senei_ta_jashu = anko_senei_ta_jashu or class({})

function anko_senei_ta_jashu:OnSpellStart()
	if not IsServer() then return end

	local target = self:GetCursorTarget()

	if target and target:IsAlive() and not target:IsOutOfGame() then
		target:AddNewModifier(self:GetCaster(), self, "modifier_anko_senei_ta_jashu_poison", {duration = self:GetSpecialValueFor("duration")})
		target:AddNewModifier(self:GetCaster(), self, "modifier_anko_senei_ta_jashu_slow", {duration = self:GetSpecialValueFor("slow_duration") + self:GetCaster():FindTalentValue("special_bonus_anko_2")})
	end

	self:GetCaster():EmitSound("anko_striking_cast")
end

modifier_anko_senei_ta_jashu_poison = modifier_anko_senei_ta_jashu_poison or class({})

function modifier_anko_senei_ta_jashu_poison:GetEffectName() return "particles/generic_gameplay/generic_silence.vpcf" end
function modifier_anko_senei_ta_jashu_poison:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_anko_senei_ta_jashu_poison:CheckState() return {
	[MODIFIER_STATE_SILENCED] = true,
} end

function modifier_anko_senei_ta_jashu_poison:OnCreated()
	if not IsServer() then return end

	self.poison_damage = self:GetAbility():GetSpecialValueFor("damage_per_tick")

	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_time"))
end

function modifier_anko_senei_ta_jashu_poison:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.poison_damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
	})

	PopupDamage(target, self.poison_damage)
end

modifier_anko_senei_ta_jashu_slow = modifier_anko_senei_ta_jashu_slow or class({})

function modifier_anko_senei_ta_jashu_slow:GetEffectName() return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf" end
function modifier_anko_senei_ta_jashu_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_anko_senei_ta_jashu_slow:GetStatusEffectName() return "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf" end
function modifier_anko_senei_ta_jashu_slow:GetPriority() return 10 end

function modifier_anko_senei_ta_jashu_slow:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
} end

function modifier_anko_senei_ta_jashu_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_slow")
end
