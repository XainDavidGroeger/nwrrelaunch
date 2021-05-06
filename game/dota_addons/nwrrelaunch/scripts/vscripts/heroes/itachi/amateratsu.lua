LinkLuaModifier("modifier_itachi_amateratsu", "heroes/itachi/amateratsu", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_itachi_amateratsu_spread_fire_cd", "heroes/itachi/amateratsu", LUA_MODIFIER_MOTION_NONE)

itachi_amateratsu = itachi_amateratsu or class({})

function itachi_amateratsu:OnSpellStart()
	if not IsServer() then return end

	self:GetCaster():EmitSound("itachi_amaterasu_cast_talking")

	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_itachi_amateratsu", {duration = self:GetSpecialValueFor("duration")})
end

modifier_itachi_amateratsu = modifier_itachi_amateratsu or class({})

function modifier_itachi_amateratsu:GetEffectName() return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf" end
function modifier_itachi_amateratsu:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_itachi_amateratsu:OnCreated()
	if not IsServer() then return end

	self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_itachi_amateratsu_spread_fire_cd", {duration = self:GetAbility():GetSpecialValueFor("spread_cd")})

	self.damage = self:GetAbility():GetSpecialValueFor("damage")

--[[
	self:GetParent():SetContextThink(DoUniqueString("sound_loop"), function()
		self:GetParent():EmitSound("itachi_amateratsu_burning")

		if self:GetParent():HasModifier("modifier_itachi_amateratsu") then
			return 0.75
		else
			return nil
		end
	end, 0.0)
--]]

	self:StartIntervalThink(1.0)
end

function modifier_itachi_amateratsu:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = self:GetAbility():GetAbilityDamageType()
	})

	self:GetParent():EmitSound("itachi_amateratsu_burning")

	local radius = self:GetAbility():GetSpecialValueFor("spread_aoe") + self:GetCaster():FindTalentValue("special_bonus_itachi_4")
	local allyEntities = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), 0, FIND_ANY_ORDER, false)

	for _,ally in pairs(allyEntities) do
		if not ally:HasModifier("modifier_itachi_amateratsu") and not ally:HasModifier("modifier_itachi_amateratsu_spread_fire_cd") then
			ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_itachi_amateratsu", {duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
	end
end

modifier_itachi_amateratsu_spread_fire_cd = modifier_itachi_amateratsu_spread_fire_cd or class({})

function modifier_itachi_amateratsu_spread_fire_cd:IsHidden() return true end
