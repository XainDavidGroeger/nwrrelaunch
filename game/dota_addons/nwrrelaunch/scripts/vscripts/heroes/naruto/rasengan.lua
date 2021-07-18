LinkLuaModifier("modifier_naruto_rasengan", "heroes/naruto/rasengan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_naruto_rasengan_slow", "heroes/naruto/rasengan", LUA_MODIFIER_MOTION_NONE)

naruto_rasengan = naruto_rasengan or class({})

function naruto_rasengan:OnSpellStart()
	if not IsServer() then return end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_naruto_rasengan", {duration = self:GetSpecialValueFor("duration")})
end

modifier_naruto_rasengan = modifier_naruto_rasengan or class({})

function modifier_naruto_rasengan:DeclareFunctions() return {
	MODIFIER_EVENT_ON_ATTACK_LANDED,
} end

function modifier_naruto_rasengan:GetAttackSound()
	return "Hero_Ancient_Apparition.ChillingTouch.Cast"
end

function modifier_naruto_rasengan:OnCreated()
	if not IsServer() then return end

	self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_projectile.vpcf")
end

function modifier_naruto_rasengan:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsMagicImmune() then return end

	keys.target:EmitSound("Hero_Ancient_Apparition.ChillingTouch.Target")
	keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_naruto_rasengan_slow", { duration = self:GetAbility():GetSpecialValueFor("knockback_duration") + self:GetAbility():GetSpecialValueFor("slow_duration")})

	local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetParent():FindTalentValue("special_bonus_naruto_rasengan_damage")

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

function modifier_naruto_rasengan:OnRemoved()
	if not IsServer() then return end

	local projectile_name = GetUnitKV(self:GetParent():GetUnitName(), "ProjectileName") or ""

	self:GetParent():SetRangedProjectileName(projectile_name)
end

modifier_naruto_rasengan_slow = modifier_naruto_rasengan_slow or class({})

function modifier_naruto_rasengan_slow:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
} end

function modifier_naruto_rasengan_slow:OnCreated()
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

function modifier_naruto_rasengan:OnIntervalThink()
	self.slow = self:GetAbility():GetVanillaAbilitySpecial("slow")
end

function modifier_naruto_rasengan_slow:GetModifierMoveSpeedBonus_Percentage()
	if self.slow then
		return self.slow * (-1)
	end
end
