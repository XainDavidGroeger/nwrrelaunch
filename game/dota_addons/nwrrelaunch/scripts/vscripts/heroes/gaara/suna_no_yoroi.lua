--[[
	Author: Noya, Pizzalol
	Date: 04.03.2015.
	After taking damage, checks the mana of the caster and prevents as many damage as possible.
	Note: This is post-reduction, because there's currently no easy way to get pre-mitigation damage.
	- Converted from datadriven to lua by EarthSalamander
	- Date: 27.04.2021
]]

LinkLuaModifier("modifier_suna_no_yoroi", "scripts/vscripts/heroes/gaara/suna_no_yoroi.lua", LUA_MODIFIER_MOTION_NONE)

gaara_suna_no_yoroi = gaara_suna_no_yoroi or class({})

function gaara_suna_no_yoroi:OnToggle()
	if not IsServer() then return end

	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_suna_no_yoroi", {})
		ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		self:GetCaster():EmitSound("Hero_Medusa.ManaShield.On")
	else
		self:GetCaster():RemoveModifierByNameAndCaster("modifier_suna_no_yoroi", self:GetCaster())
		ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		self:GetCaster():EmitSound("Hero_Medusa.ManaShield.Off")
	end
end

modifier_suna_no_yoroi = modifier_suna_no_yoroi or class({})

function modifier_suna_no_yoroi:IsPurgable() return false end
function modifier_suna_no_yoroi:GetEffectName() return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf" end

function modifier_suna_no_yoroi:DeclareFunctions() return {
	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
} end

function modifier_suna_no_yoroi:OnCreated()
	if not IsServer() then return end

	self.damage_per_mana = self:GetAbility():GetSpecialValueFor("damage_per_mana") + self:GetParent():FindTalentValue("special_bonus_gaara_1")
	self.absorption_tooltip = self:GetAbility():GetSpecialValueFor("absorption_tooltip")
end

function modifier_suna_no_yoroi:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() then return end
	
	-- "While spell immune, Mana Shield does not react on magical damage."
	if not (keys.damage_type == DAMAGE_TYPE_MAGICAL and self:GetParent():IsMagicImmune()) and self:GetParent().GetMana then
		-- Calculate how much mana will be used in attempts to block some damage
		local mana_to_block	= keys.original_damage * self.absorption_tooltip * 0.01 / self.damage_per_mana

		if mana_to_block >= self:GetParent():GetMana() then
			self:GetParent():EmitSound("Hero_Medusa.ManaShield.Proc")

			local shield_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:ReleaseParticleIndex(shield_particle)
		end			

		local mana_before = self:GetParent():GetMana()
		self:GetParent():ReduceMana(mana_to_block)
		local mana_after = self:GetParent():GetMana()

		return math.min(self.absorption_tooltip, self.absorption_tooltip * self:GetParent():GetMana() / math.max(mana_to_block, 1)) * (-1)
	end
end
