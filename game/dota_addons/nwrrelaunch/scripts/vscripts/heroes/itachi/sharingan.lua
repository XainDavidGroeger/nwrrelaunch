LinkLuaModifier("modifier_itachi_sharingan", "heroes/itachi/sharingan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_itachi_sharingan_mr_reduce", "heroes/itachi/sharingan", LUA_MODIFIER_MOTION_NONE)

itachi_sharingan = itachi_sharingan or class({})

function itachi_sharingan:GetIntrinsicModifierName()
	return "modifier_itachi_sharingan"
end

modifier_itachi_sharingan = modifier_itachi_sharingan or class({})

function modifier_itachi_sharingan:IsPassive() return true end
function modifier_itachi_sharingan:IsHidden() return true end

function modifier_itachi_sharingan:DeclareFunctions() return {
	MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	MODIFIER_EVENT_ON_ATTACK_LANDED,
} end

function modifier_itachi_sharingan:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	if self.caster:IsIllusion() then return end

	-- Ability specials
	self.crit_bonus = self:GetAbility():GetSpecialValueFor("crit_bonus")
	self.crit_chance = self:GetAbility():GetTalentSpecialValueFor("chance")
end

function modifier_itachi_sharingan:OnRefresh()
	self:OnCreated()
end

function modifier_itachi_sharingan:GetModifierPreAttack_CriticalStrike(keys)
	if not self:GetParent():PassivesDisabled() then
		local target = keys.target

		-- Ignore crit for buildings
		if target:IsBuilding() or target:IsOther() or keys.target:GetTeamNumber() == keys.attacker:GetTeamNumber() then
			return
		end

		if RollPseudoRandom(self.crit_chance, self) then
			-- Mark the attack as a critical in order to play the bloody effect on attack landed
			self.crit_strike = true
			return self.crit_bonus
		else
			-- If this attack wasn't a critical strike, remove possible markers from it.
			self.crit_strike = false
		end

		return nil
	end
end

function modifier_itachi_sharingan:OnAttackLanded(keys)
	if not IsServer() then return end

	local target = keys.target
	local attacker = keys.attacker

	-- Only apply if the attacker is the caster and it was a critical strike
	if self:GetCaster() == attacker then
		if target:IsBuilding() or target:IsRoshan() or target:GetTeamNumber() == attacker:GetTeamNumber() then
			return
		end

		if self.crit_strike ~= false then
			-- If that attack was marked as a critical strike, apply the particles
			local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, self.caster)
			ParticleManager:SetParticleControlEnt(coup_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(coup_pfx, 1, target:GetAbsOrigin())
			ParticleManager:SetParticleControlOrientation(coup_pfx, 1, self:GetParent():GetForwardVector() * (-1), self:GetParent():GetRightVector(), self:GetParent():GetUpVector())
			ParticleManager:ReleaseParticleIndex(coup_pfx)

			local duration	= self:GetAbility():GetSpecialValueFor("duration")
			local damage	= attacker:GetBaseDamageMax()

			if attacker:IsRealHero() and not attacker:IsIllusion() then
				attacker:EmitSound("itachi_sharingan_proc")
			end

			target:AddNewModifier(attacker, self:GetAbility(), "modifier_itachi_sharingan_mr_reduce", {duration = duration})
		end
	end
end

modifier_itachi_sharingan_mr_reduce = modifier_itachi_sharingan_mr_reduce or class({})

function modifier_itachi_sharingan_mr_reduce:DeclareFunctions() return {
	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
} end

function modifier_itachi_sharingan_mr_reduce:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("mr_reduction")
end
