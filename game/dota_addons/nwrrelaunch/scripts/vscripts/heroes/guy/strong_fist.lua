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
LinkLuaModifier("modifier_guy_morning_peacock_attacks", "heroes/guy/strong_fist.lua", LUA_MODIFIER_MOTION_NONE)

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
	local morning_peacock_bonus_attack_count = ability:GetSpecialValueFor("morning_peacock_bonus_attack_count")
	local morning_peacock_attack_interval = ability:GetSpecialValueFor("morning_peacock_attack_interval")

	if caster:HasTalent("special_bonus_guy_4") and caster:HasModifier("modifier_guy_seventh_gate") then
		--Morning peacock
		local morning_peacock_duration = morning_peacock_bonus_attack_count * morning_peacock_attack_interval
		target:AddNewModifier(
			caster, 
			ability, 
			"modifier_guy_morning_peacock_attacks", 
			{
				duration = morning_peacock_duration,
				attack_damage = attack_event.damage
			}
		)

		EmitSoundOn("guy_morningpeacock_talking", caster)
		EmitSoundOn("guy_morningpeacock_impact", target)

	else
		--normal behaviour
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

			EmitSoundOn("guy_gouken_talking_6", caster)
			EmitSoundOn("guy_gouken_impact_6", target)

			--VFXs
			local impact_vfx = ParticleManager:CreateParticle(
				"particles/units/heroes/guy_strong_fist_gates_impact.vpcf",
				PATTACH_CUSTOMORIGIN_FOLLOW, 
				target
			)
			ParticleManager:SetParticleControl(impact_vfx, 3, caster:GetForwardVector():Normalized())
			ParticleManager:SetParticleControlEnt(
				impact_vfx,
				0,
				target,
				PATTACH_POINT_FOLLOW,
				"attach_hitloc",
				Vector(0,0,0), -- unknown
				true -- unknown, true
			)
			ParticleManager:SetParticleControlEnt(
				impact_vfx,
				4,
				target,
				PATTACH_POINT_FOLLOW,
				"attach_hitloc",
				Vector(0,0,0), -- unknown
				true -- unknown, true
			)
		else
			
			EmitSoundOn("guy_gouken_talking", caster)
			EmitSoundOn("guy_gouken_impact", target)


			--VFXs
			local impact_vfx = ParticleManager:CreateParticle(
				"particles/units/heroes/guy_strong_fist_impact.vpcf",
				PATTACH_CENTER_FOLLOW, 
				target
			)
			ParticleManager:SetParticleControl(impact_vfx, 3, caster:GetForwardVector():Normalized())
			ParticleManager:SetParticleControlEnt(
				impact_vfx,
				0,
				target,
				PATTACH_POINT_FOLLOW,
				"attach_hitloc",
				Vector(0,0,0), -- unknown
				true -- unknown, true
			)
			ParticleManager:SetParticleControlEnt(
				impact_vfx,
				4,
				target,
				PATTACH_POINT_FOLLOW,
				"attach_hitloc",
				Vector(0,0,0), -- unknown
				true -- unknown, true
			)
			print(target:GetOrigin())
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
end


modifier_guy_strong_fist_caster = class({})

function modifier_guy_strong_fist_caster:IsHidden() return true end

function modifier_guy_strong_fist_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH
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
		end
	end
	strong_fist_ability.activated = false
	strong_fist_ability:SetCooldownSpeed(1)
end

function modifier_guy_strong_fist_caster:OnDeath(event_table)
	if event_table.unit ~= self:GetParent() then return end
	local strong_fist_ability = self:GetAbility()
	strong_fist_ability.activated = false
	strong_fist_ability:SetCooldownSpeed(1)
end


modifier_guy_morning_peacock_attacks = class({})

function modifier_guy_morning_peacock_attacks:IsHidden() return true end

function modifier_guy_morning_peacock_attacks:OnCreated(kv)
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.caster = self.ability:GetCaster()
	self.stun_duration = self.ability:GetSpecialValueFor("stun")

	local morning_peacock_attack_interval = self.ability:GetSpecialValueFor("morning_peacock_attack_interval")
	local morning_peacock_attack_damage_perc = self.ability:GetSpecialValueFor("morning_peacock_attack_damage_perc")
	self.attack_damage = kv.attack_damage
	self:StartIntervalThink(morning_peacock_attack_interval)
	self.damage_table = {
		victim = self.parent,
		attacker = self.caster,
		damage = (self.attack_damage * morning_peacock_attack_damage_perc) / 100,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = 0
	}
end

function modifier_guy_morning_peacock_attacks:OnIntervalThink()
	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_CRITICAL,
		self.parent,
		self.damage_table.damage,
		self.ability:GetCaster():GetPlayerOwner()
	)

	--VFXs
	local impact_vfx = ParticleManager:CreateParticle(
		"particles/units/heroes/guy_morning_peacock_impact.vpcf",
		PATTACH_CUSTOMORIGIN_FOLLOW, 
		self.parent
	)

	ParticleManager:SetParticleControlEnt(
		impact_vfx,
		0,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		impact_vfx,
		1,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	if not IsServer() then return end
	ApplyDamage(self.damage_table)
	print("damage done")

	self.parent:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = self.stun_duration})
end