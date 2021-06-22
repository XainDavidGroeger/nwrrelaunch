function playSound( keys )

	if keys.ability:GetName() == "guy_leaf_strong_whirlwind_ult" then 
		keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_END, 3.0)
		Timers:CreateTimer(0.1, function()
			keys.caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2_END)
		end)
	else
		keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_END, 1.0)
		Timers:CreateTimer(0.3, function()
			keys.caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2_END)
		end)
	end

end

function effectStart( keys )
	local caster = keys.caster
	local particle_caster = ParticleManager:CreateParticle("particles/units/heroes/guy/senpuu_tornado.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster, 3, caster:GetAbsOrigin())

	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2_END)
end

function performAttackOnTarget(keys)

	local ability1 = keys.caster:FindAbilityByName("special_bonus_guy_1")
	if ability1 ~= nil then
	    if ability1:IsTrained() then
	    	
			local damage = keys.caster:GetAverageTrueAttackDamage(nil) / 100 * 35
			ApplyDamage({
				attacker = keys.caster,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = keys.ability,
				victim = keys.target,
				damage = damage,
			})
	    end
	end

	keys.caster:PerformAttack(keys.target, true, true, true, true, false, false, false)

end

LinkLuaModifier("modifier_guy_string_whirlwind_bonus_damage", "heroes/guy/leaf_strong_whirlwind.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guy_string_whirlwind_slow_debuff", "heroes/guy/leaf_strong_whirlwind.lua", LUA_MODIFIER_MOTION_NONE)

guy_leaf_strong_whirlwind = class({})

function guy_leaf_strong_whirlwind:OnAbilityPhaseStart()
	EmitSoundOn("guy_senpu_cast", self:GetCaster())

	return true
end

function guy_leaf_strong_whirlwind:GetAbilityTextureName()
	local texture = "guy_leaf_strong_whirlwind"
	local caster = self:GetCaster()
	if not caster then return texture end
	if caster:HasModifier("modifier_guy_seventh_gate") then
		texture = "guy_leaf_strong_whirlwind_gates"
	end
	return texture
end

function guy_leaf_strong_whirlwind:ProcsMagicStick()
	return true
end

function guy_leaf_strong_whirlwind:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local particle_caster

	if caster:HasModifier("modifier_guy_seventh_gate") then
		particle_caster = ParticleManager:CreateParticle(
			"particles/units/heroes/guy/senpuu_gates_tornado.vpcf",
			PATTACH_ABSORIGIN, 
			caster)
		ParticleManager:SetParticleControl(particle_caster, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_caster, 3, caster:GetAbsOrigin())
	else
		particle_caster = ParticleManager:CreateParticle(
			"particles/units/heroes/guy/senpuu_tornado.vpcf",
			PATTACH_ABSORIGIN, 
			caster)
		ParticleManager:SetParticleControl(particle_caster, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_caster, 3, caster:GetAbsOrigin())
	end

	local damage_table = {
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		damage_flags = 0,
		ability = self,
	}

	local units_in_radius = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		DOTA_UNIT_TARGET_FLAG_NONE, 
		FIND_ANY_ORDER, 
		false)

	for _,target in pairs(units_in_radius) do
		damage_table.victim = target
		ApplyDamage(damage_table)

		if caster:HasTalent("special_bonus_guy_1") then
			caster:AddNewModifier(caster, self, "modifier_guy_string_whirlwind_bonus_damage", {})
		end

		caster:PerformAttack(
			target, --target
			true, --useCastAttackOrb
			true, --processProcs
			true, --skipCooldown
			true, --ignoreInvis
			false, --useProjectile
			false, --fakeAttack
			false  --neverMiss
		)

		local bonus_damage_modifier = caster:FindModifierByName("modifier_guy_string_whirlwind_bonus_damage")
		if bonus_damage_modifier then
			bonus_damage_modifier:Destroy()
		end

		target:AddNewModifier(caster, self, "modifier_guy_string_whirlwind_slow_debuff", {duration = slow_duration})

	end
end

function guy_leaf_strong_whirlwind:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2_END
end

function guy_leaf_strong_whirlwind:ProcsMagicStick()
	return true
end

function guy_leaf_strong_whirlwind:GetPlaybackRateOverride()
	if self:GetCaster():HasModifier("modifier_guy_seventh_gate") then
		return 3.0
	else
		return 1.0
	end
end

function guy_leaf_strong_whirlwind:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_guy_seventh_gate") then
		return 0.1
	else
		return 0.3
	end
end

modifier_guy_string_whirlwind_slow_debuff = class({})

function modifier_guy_string_whirlwind_slow_debuff:IsHidden() return false end
function modifier_guy_string_whirlwind_slow_debuff:IsBuff() return false end
function modifier_guy_string_whirlwind_slow_debuff:IsDebuff() return true end
function modifier_guy_string_whirlwind_slow_debuff:IsPurgable() return true end


function modifier_guy_string_whirlwind_slow_debuff:OnCreated()
	local ability = self:GetAbility()
	local caster = ability:GetCaster()

	if caster:HasModifier("modifier_guy_seventh_gate") then
		self.slow_value = ability:GetSpecialValueFor("slow_value_ult")
		self.effect_name = "particles/units/heroes/guy/guy_senpuu_slow_gates.vpcf"

		EmitSoundOn("guy_senpu_impact_6", caster)

	else
		self.slow_value = ability:GetSpecialValueFor("slow_value")
		self.effect_name = "particles/units/heroes/guy/guy_senpuu_slow_base.vpcf"

		EmitSoundOn("guy_senpu_impact", caster)
	end
end

function modifier_guy_string_whirlwind_slow_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_guy_string_whirlwind_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self.slow_value
end

function modifier_guy_string_whirlwind_slow_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_guy_string_whirlwind_slow_debuff:GetEffectName()
	return self.effect_name
end


modifier_guy_string_whirlwind_bonus_damage = class({})

function modifier_guy_string_whirlwind_bonus_damage:IsHidden() return true end
function modifier_guy_string_whirlwind_bonus_damage:IsPurgable() return false end


function modifier_guy_string_whirlwind_bonus_damage:OnCreated()
	self.damage_value = self:GetAbility():GetCaster():FindTalentValue("special_bonus_guy_1")
end

function modifier_guy_string_whirlwind_bonus_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE 
	}
end

function modifier_guy_string_whirlwind_bonus_damage:GetModifierProcAttack_Feedback()
	return self.damage_value
end