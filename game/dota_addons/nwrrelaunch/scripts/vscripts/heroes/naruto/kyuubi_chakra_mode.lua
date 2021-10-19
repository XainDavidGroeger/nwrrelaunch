LinkLuaModifier("modifier_kyuubi_chakra_mode", "heroes/naruto/kyuubi_chakra_mode.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kyuubi_chakra_mode_magic_immune", "heroes/naruto/kyuubi_chakra_mode.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kyuubi_chakra_mode_crit", "heroes/naruto/kyuubi_chakra_mode", LUA_MODIFIER_MOTION_NONE)

naruto_kyuubi_chakra_mode = naruto_kyuubi_chakra_mode or class({})

function naruto_kyuubi_chakra_mode:Precache( context )
	PrecacheResource( "soundfile", "soundevents/heroes/naruto/kcm_cast_talking.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/heroes/naruto/kcm_cast.vsndevts", context )
end

function naruto_kyuubi_chakra_mode:OnSpellStart()
	if not IsServer() then return end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kyuubi_chakra_mode", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kyuubi_chakra_mode_magic_immune", {duration = self:GetSpecialValueFor("magic_immune_duration")})

	self:GetCaster():EmitSound("kcm_cast_talking")
	self:GetCaster():EmitSound("kcm_cast")
end

modifier_kyuubi_chakra_mode = modifier_kyuubi_chakra_mode or class({})

function modifier_kyuubi_chakra_mode:IsPurgable() return false end

function modifier_kyuubi_chakra_mode:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
} end

function modifier_kyuubi_chakra_mode:OnCreated()
	if not IsServer() then return end

	self:GetParent():SwapAbilities("naruto_rasengan", "naruto_rasenshuriken", false, true)

	if self:GetAbility():GetLevel() >= 2 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kyuubi_chakra_mode_crit", {duration = self:GetDuration()})
	end

	if self:GetAbility():GetLevel() >= 3 then
		local tailed_beast_bomb = self:GetCaster():FindAbilityByName("naruto_tailed_beast_bomb")

		if tailed_beast_bomb then
			tailed_beast_bomb:StartCooldown(self:GetAbility():GetSpecialValueFor("tailed_beast_bomb_cd"))
			tailed_beast_bomb:SetHidden(false)
		end
	end
end

function modifier_kyuubi_chakra_mode:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_kyuubi_chakra_mode:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("base_attack_time")
end

function modifier_kyuubi_chakra_mode:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_kyuubi_chakra_mode:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_kyuubi_chakra_mode:OnRemoved()
	if not IsServer() then return end

	self:GetParent():SwapAbilities("naruto_rasengan", "naruto_rasenshuriken", true, false)

	local tailed_beast_bomb = self:GetCaster():FindAbilityByName("naruto_tailed_beast_bomb")

	if tailed_beast_bomb then
		tailed_beast_bomb:SetHidden(true)
	end

	self:GetParent():RemoveModifierByName("modifier_kyuubi_chakra_mode_crit")
end

modifier_kyuubi_chakra_mode_magic_immune = modifier_kyuubi_chakra_mode_magic_immune or class({})

function modifier_kyuubi_chakra_mode_magic_immune:GetEffectName() return "particles/items_fx/black_king_bar_avatar.vpcf" end
function modifier_kyuubi_chakra_mode_magic_immune:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_kyuubi_chakra_mode_magic_immune:CheckState() return {
	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
} end

modifier_kyuubi_chakra_mode_crit = modifier_kyuubi_chakra_mode_crit or class({})

function modifier_kyuubi_chakra_mode_crit:IsHidden() return true end

function modifier_kyuubi_chakra_mode_crit:DeclareFunctions() return {
	MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	MODIFIER_EVENT_ON_ATTACK_LANDED,
} end

function modifier_kyuubi_chakra_mode_crit:OnCreated()
	if not IsServer() then return end

	self.critProc = false
end

function modifier_kyuubi_chakra_mode_crit:GetModifierPreAttack_CriticalStrike(keys)
	if not IsServer() then return end
	if self:GetParent():PassivesDisabled() then return nil end

	if self:GetAbility() and keys.attacker == self:GetParent() then
		self.critProc = false

		if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self) then
--			self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetSecondsPerAttack()) -- different attack animation on crit

			local crit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

			ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(crit_pfx)

			self.critProc = true
			self:GetParent():EmitSound("Hero_Juggernaut.BladeDance", self:GetCaster())

			return self:GetAbility():GetSpecialValueFor("crit_mult")
		end
	end
end

function modifier_kyuubi_chakra_mode_crit:OnAttackLanded(params)
	if not IsServer() then return end

	if params.attacker == self:GetParent() then
		if self.critProc == true then
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_crit_tgt.vpcf", PATTACH_ABSORIGIN, params.target, self:GetCaster())
			ParticleManager:SetParticleControl(particle, 0, params.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle)

			self.critProc = false
		end
	end
end
