function resetCooldown( keys )
	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1))
end

function resetCooldownOnHit( keys )
	if keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() and not keys.target:IsBuilding() then	
		local ability = keys.caster:FindAbilityByName("guy_strong_fist")
		local ability_ult = keys.caster:FindAbilityByName("guy_strong_fist_ult")

		if ability ~= nil then
			if not ability:IsCooldownReady() then
				local new_cd = ability:GetCooldownTimeRemaining() - 1.0
				ability:EndCooldown()
				ability:StartCooldown(new_cd)
			end
		end	

		if ability_ult ~= nil then 
			if not ability_ult:IsCooldownReady() then
				local new_cd = ability_ult:GetCooldownTimeRemaining() - 1.0
				ability_ult:EndCooldown()
				ability_ult:StartCooldown(new_cd)
			end	
		end		
	end
end

LinkLuaModifier("modifier_guy_strong_fist_caster", "heroes/guy/strong_fist.lua", LUA_MODIFIER_MOTION_NONE)

guy_strong_fist = class({})

function guy_strong_fist:Init()
	self.activated = false
end

function guy_strong_fist:GetIntrinsicModifierName()
	return "modifier_guy_strong_fist_caster"
end

function guy_strong_fist:GetAbilityTextureName()
	local texture = "guy_strong_fist"
	local caster = self:GetCaster()
	if not caster then return texture end
	if caster:HasModifier("modifier_guy_seventh_gate") then
		if caster:HasTalent("special_bonus_guy_4") then
			texture = "guy_morning_peacock"
		else
			texture = "guy_strong_fist_gates"
		end
	end
	return texture
end

function guy_strong_fist:OnSpellStart()
	self.activated = true
	-- self:StartCooldown(self:GetCooldown(self:GetLevel() - 1))
	self:SetCooldownSpeed(0)
end

function PerformCritAttack(ability, attack_event)
	local target = attack_event.target
	local caster = ability:GetCaster()
	local crit_fraction = (ability:GetSpecialValueFor("crit") - 100) / 100
	local bonus_damage = attack_event.damage * crit_fraction
	local full_damage = attack_event.damage + bonus_damage
	local stun_duration = ability:GetSpecialValueFor("stun")

	local bonus_damage_table = {
		victim = target,
		attacker = caster,
		damage = bonus_damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}
	ApplyDamage(bonus_damage_table)

	if caster:HasModifier("modifier_guy_seventh_gate") then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
	end

	--visual numbers
	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_CRITICAL,
		target,
		full_damage,
		caster:GetPlayerOwner()
	)
end


modifier_guy_strong_fist_caster = class({})

function modifier_guy_strong_fist_caster:IsHidden() return true end

function modifier_guy_strong_fist_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_guy_strong_fist_caster:OnAttackLanded(attack_event)
	if attack_event.attacker ~= self:GetAbility():GetCaster() then return end
	if attack_event.fail_type ~= 0 then return end --attack failed


	--cooldown reduction
	local strong_fist_ability = self:GetAbility()
	local cd_reduction = 1

	if not strong_fist_ability:IsCooldownReady() then
		local left = strong_fist_ability:GetCooldownTimeRemaining()
		strong_fist_ability:EndCooldown()
		strong_fist_ability:StartCooldown(left - cd_reduction)
	end

	if strong_fist_ability:GetAutoCastState() then
		--if is set on outocast
		if strong_fist_ability:IsCooldownReady() then
			PerformCritAttack(strong_fist_ability, attack_event)
			strong_fist_ability:StartCooldown(strong_fist_ability:GetCooldown(strong_fist_ability:GetLevel() - 1))
		end
	else
		if strong_fist_ability.activated then
			PerformCritAttack(strong_fist_ability, attack_event)
			strong_fist_ability:SetCooldownSpeed(1)
		end
	end
	strong_fist_ability.activated = false
end

