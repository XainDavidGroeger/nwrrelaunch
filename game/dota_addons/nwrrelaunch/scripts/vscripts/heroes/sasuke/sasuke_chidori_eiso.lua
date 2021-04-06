sasuke_chidori_eiso = sasuke_chidori_eiso or class({})

function sasuke_chidori_eiso:GetAbilityTextureName()
	return "sasuke_chidori_eiso"
end

function sasuke_chidori_eiso:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_chidori_eiso:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_sasuke_3"):GetLevel() > 0 then
		castrangebonus = 450
	end
	return self:GetSpecialValueFor("cast_range") + castrangebonus
end

function sasuke_chidori_eiso:OnSpellStart()

	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local particle = "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf"
	local ability = self
	local duration = ability:GetSpecialValueFor("stun_duration")
	local damage = ability:GetSpecialValueFor("damage")
	local castrange = ability:GetSpecialValueFor("cast_range")

	caster:EmitSound("Ability.PlasmaFieldImpact")

	-- Lightning particle
	local pid = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(pid, 0, target:GetAbsOrigin() + Vector(0, 0, 75))
    ParticleManager:SetParticleControl(pid, 1, caster:GetAbsOrigin() + Vector(0, 0, 75))

	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = duration})

	-- damage
	local applydamage = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	ApplyDamage( applydamage )

end