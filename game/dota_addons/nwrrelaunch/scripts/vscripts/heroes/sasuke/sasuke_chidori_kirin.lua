sasuke_chidori_kirin = sasuke_chidori_kirin or class({})

LinkLuaModifier("modifier_chidori_kirin_mark", "scripts/vscripts/heroes/sasuke/sasuke_chidori_kirin.lua", LUA_MODIFIER_MOTION_NONE)

function sasuke_chidori_kirin:GetAbilityTextureName()
	return "sasuke_chidori_kirin"
end

function sasuke_chidori_kirin:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_chidori_kirin:GetCastRange(location, target)
	return self:GetSpecialValueFor("radius")
end

function sasuke_chidori_kirin:OnSpellStart()
	self:GetCaster():EmitSound("sasuke_kirin_cast_talking")
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_chidori_kirin_mark", {duration = self:GetSpecialValueFor("duration")})
end

modifier_chidori_kirin_mark = modifier_chidori_kirin_mark or class({})

function modifier_chidori_kirin_mark:IsHidden() return false end
function modifier_chidori_kirin_mark:IsDebuff() return true end

function modifier_chidori_kirin_mark:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	
	return decFuncs
end

function modifier_chidori_kirin_mark:OnCreated()

	self.caster = self:GetCaster()
	self.stored_damage = 0

	-- add prepare effect
	self.storm = ParticleManager:CreateParticle("particles/units/heroes/sasuke/kirin/storm_core.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( self.storm, 0, self:GetParent():GetAbsOrigin() )

end

function modifier_chidori_kirin_mark:OnTakeDamage(keys)
	-- store damage
	if keys.attacker == self.caster then
		self.stored_damage = self.stored_damage + keys.damage
	end
end

function modifier_chidori_kirin_mark:OnDestroy()

	ParticleManager:DestroyParticle(self.storm, true)
	ParticleManager:ReleaseParticleIndex(self.storm)

	self:GetCaster():EmitSound("sasuke_kirin_impact_talking")

	self.lighting_bolt = ParticleManager:CreateParticle("particles/units/heroes/sasuke/kirin/lighting_bolt.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.lighting_bolt, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.lighting_bolt, 1, self:GetParent():GetAbsOrigin() * Vector(0, 0, 5))

	local damage = self:GetAbility():GetSpecialValueFor("base_damage")
	if self.stored_damage > 0 then
		damage = damage + (self.stored_damage * ( self:GetAbility():GetSpecialValueFor("lost_health_bonus_damage") / 100 ))
	end

	local damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(), 
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility()
	}
	ApplyDamage(damageTable)  

end