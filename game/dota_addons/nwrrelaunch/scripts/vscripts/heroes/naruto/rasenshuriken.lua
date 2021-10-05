LinkLuaModifier("modifier_naruto_rasenshuriken", "heroes/naruto/rasenshuriken", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_naruto_rasenshuriken_slow", "heroes/naruto/rasenshuriken", LUA_MODIFIER_MOTION_NONE)

naruto_rasenshuriken = naruto_rasenshuriken or class({})

function naruto_rasenshuriken:OnSpellStart()
	if not IsServer() then return end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_naruto_rasenshuriken", {duration = self:GetSpecialValueFor("duration")})
end

modifier_naruto_rasenshuriken = modifier_naruto_rasenshuriken or class({})

function modifier_naruto_rasenshuriken:DeclareFunctions() return {
	MODIFIER_EVENT_ON_ATTACK_LANDED,
	MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
} end

function modifier_naruto_rasenshuriken:GetAttackSound()
	return "Hero_Ancient_Apparition.ChillingTouch.Cast"
end

function modifier_naruto_rasenshuriken:OnCreated()
	if not IsServer() then return end

	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_projectile.vpcf")
end

function modifier_naruto_rasenshuriken:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsMagicImmune() then return end

	keys.target:EmitSound("Hero_Ancient_Apparition.ChillingTouch.Target")
	keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_naruto_rasenshuriken_slow", { duration = self:GetAbility():GetSpecialValueFor("knockback_duration") + self:GetAbility():GetSpecialValueFor("slow_duration")})
	keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_stunned", { duration = self:GetAbility():GetSpecialValueFor("stun_duration")})

	local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetParent():FindTalentValue("special_bonus_naruto_rasenshuriken_damage")

	ApplyDamage({
		victim 			= keys.target,
		damage 			= damage,
		damage_type		= self:GetAbility():GetAbilityDamageType(),
		damage_flags 	= self:GetAbility():GetAbilityTargetFlags(),
		attacker 		= self:GetParent(),
		ability 		= self:GetAbility()
	})

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, damage, nil)

	self:Destroy()
end

function modifier_naruto_rasenshuriken:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_range")
end

function modifier_naruto_rasenshuriken:OnRemoved()
	if not IsServer() then return end

	local projectile_name = GetUnitKV(self:GetParent():GetUnitName(), "ProjectileName") or ""

	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	self:GetParent():SetRangedProjectileName(projectile_name)
end

modifier_naruto_rasenshuriken_slow = modifier_naruto_rasenshuriken_slow or class({})

function modifier_naruto_rasenshuriken_slow:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
} end

function modifier_naruto_rasenshuriken_slow:OnCreated()
	self.slow = 0

	if not IsServer() then return end

	local direction = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
	local knockback_pos = self:GetParent():GetAbsOrigin() + direction * self:GetAbility():GetSpecialValueFor("knockback_distance")

	self:GetParent():RemoveModifierByName("modifier_knockback")

	self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_knockback", {
		should_stun = 1,
		knockback_duration = self:GetAbility():GetSpecialValueFor("knockback_duration"),
		duration = self:GetAbility():GetSpecialValueFor("knockback_duration"),
		knockback_distance = self:GetAbility():GetSpecialValueFor("knockback_distance"),
		knockback_height = 0,
		center_x = knockback_pos.x,
		center_y = knockback_pos.y,
		center_z = knockback_pos.z
	})

	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("knockback_duration"))
end

function modifier_naruto_rasenshuriken:OnIntervalThink()
	self.slow = self:GetAbility():GetVanillaAbilitySpecial("slow")
end

function modifier_naruto_rasenshuriken_slow:GetModifierMoveSpeedBonus_Percentage()
	if self.slow then
		return self.slow * (-1)
	end
end
