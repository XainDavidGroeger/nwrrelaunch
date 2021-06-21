guy_dynamic_entry = guy_dynamic_entry or class({})
LinkLuaModifier( "modifier_guy_dynamic_entry_debuff", "scripts/vscripts/heroes/guy/guy_dynamic_entry.lua", LUA_MODIFIER_MOTION_NONE )

function guy_dynamic_entry:GetAbilityTextureName()
	return "guy_dynamic_entry"
end

function guy_dynamic_entry:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf", context)

	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/heroes/guy/guy_dynamic_entry_talking.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/heroes/guy/guy_dynamic_entry_talking_6.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/heroes/guy/guy_dynamic_entry_cast.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/guy_dynamic_entry.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/guy_dynamic_entry_impact_6.vsndevts", context)
end

function guy_dynamic_entry:GetCastRange(location, target)
	local caster = self:GetCaster()

	if self:GetCaster():HasModifier("modifier_guy_seventh_gate") then
		return self:GetSpecialValueFor("cast_range_ulti") + caster:FindTalentValue("special_bonus_guy_5")
	else
		return self:GetSpecialValueFor("cast_range") + caster:FindTalentValue("special_bonus_guy_5")
	end
end

function guy_dynamic_entry:ProcsMagicStick()
    return true
end

function guy_dynamic_entry:GetAbilityTextureName()
	local texture = "guy_dynamic_entry"
	local caster = self:GetCaster()
	if not caster then return texture end
	if caster:HasModifier("modifier_guy_seventh_gate") then
		texture = "guy_dynamic_entry_gates"
	end
	return texture
end

function guy_dynamic_entry:OnSpellStart()

	if self:GetCaster():HasModifier("modifier_guy_seventh_gate") then
		self:GetCaster():EmitSound("guy_dynamic_entry_talking_6")
	  else
		self:GetCaster():EmitSound("guy_dynamic_entry_talking")
	  end
	
	self:GetCaster():EmitSound("guy_dynamic_entry_cast")

	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	self.point = self.target:GetAbsOrigin()
	self.ability = self
	self.distance = 0
	
	add_physics(self.caster)

	local timer_tbl =
		{
			callback = dynamic_entry_periodic,
			point = self.caster:GetAbsOrigin(),
			caster = self.caster,
			target = self.target,
			distance = self.distance,
			ability = self.ability
		}
	
	--Movement
	Timers:CreateTimer(timer_tbl)

end

function add_physics(caster)
	Physics:Unit(caster)
	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)	
end

function remove_physics(caster)
	caster:SetPhysicsAcceleration(Vector(0,0,0))
	caster:SetPhysicsVelocity(Vector(0,0,0))
	caster:OnPhysicsFrame(nil)
	caster:PreventDI(false)
	--caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
	caster:SetAutoUnstuck(true)
	caster:FollowNavMesh(true)
	caster:RemoveModifierByName("modifier_dynamic_entry_stunned")
end

function dynamic_entry_hit(target, caster, ability)
	local damage = ability:GetAbilityDamage()
	local particle_impact = "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf"
	local duration = ability:GetSpecialValueFor("duration")

	if target:IsMagicImmune() == false then
		target:AddNewModifier(caster, ability, "modifier_guy_dynamic_entry_debuff", {duration = duration})
		ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})		
	end

	local particle

	if caster:HasModifier("modifier_guy_seventh_gate") then
		
		EmitSoundOn("guy_dynamic_entry_impact_6",target)
		
		particle = ParticleManager:CreateParticle(
			"particles/units/heroes/guy/guy_dynamic_entry_six_gates_impact_base.vpcf", 
			PATTACH_ABSORIGIN_FOLLOW, 
			target) 
	else
		
		EmitSoundOn("Hero_Brewmaster.ThunderClap",caster)
		EmitSoundOn("Hero_Brewmaster.ThunderClap.Target",target)
		
		particle = ParticleManager:CreateParticle(
			"particles/units/heroes/guy/guy_dynamic_entry_impact_base.vpcf", 
			PATTACH_ABSORIGIN_FOLLOW, 
			target) 
	end
	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 2, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 3, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 6, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", Vector(100,1,1), true)
		  
end

function dynamic_entry_periodic(gameEntity, keys)
	local target = keys.target
	local caster = keys.caster

	local velocity = 2500

	local vector = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local direction = vector:Normalized()
	
	caster:SetPhysicsVelocity(direction * velocity)
	
	--Target reached
	if vector:Length2D() <= 2*caster:GetPaddedCollisionRadius() then
		dynamic_entry_hit(target, caster, keys.ability)
		remove_physics(caster)
		return nil
	end
	
	local dist = caster:GetAbsOrigin() - keys.point
	keys.distance = keys.distance + dist:Length2D()
	
	--Abort Distance / caster died / target died
	if ( keys.distance >= 15000 ) or (not caster:IsAlive()) or (not target:IsAlive()) or (target:IsNull()) then
		remove_physics(caster)
		return nil
	end
	
	return 0.03
end

modifier_guy_dynamic_entry_debuff = modifier_guy_dynamic_entry_debuff or class({})

function modifier_guy_dynamic_entry_debuff:IsHidden() return false end
function modifier_guy_dynamic_entry_debuff:IsDebuff() return true end

function modifier_guy_dynamic_entry_debuff:OnCreated()
	ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.ms_debuff = ability:GetSpecialValueFor("ms_slow")
	self.ms_debuff_ulti = ability:GetSpecialValueFor("ms_slow_ulti")

	if self.caster:HasModifier("modifier_guy_seventh_gate") then
		self.armor_debuff = ability:GetSpecialValueFor("armor_debuff_ulti")
		self.debuff_vfx = "particles/units/heroes/guy/guy_dynamic_entry_armor_debuff_gates.vpcf"
	else
		self.armor_debuff = ability:GetSpecialValueFor("armor_debuff")
		self.debuff_vfx = "particles/units/heroes/guy/guy_dynamic_entry_armor_debuff_base.vpcf"
	end
end

function modifier_guy_dynamic_entry_debuff:OnRefresh()
	ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.ms_debuff = ability:GetSpecialValueFor("ms_slow")
	self.ms_debuff_ulti = ability:GetSpecialValueFor("ms_slow_ulti")

	if self.caster:HasModifier("modifier_guy_seventh_gate") then
		self.armor_debuff = ability:GetSpecialValueFor("armor_debuff_ulti")
		self.debuff_vfx = "particles/units/heroes/guy/guy_dynamic_entry_armor_debuff_gates.vpcf"
	else
		self.armor_debuff = ability:GetSpecialValueFor("armor_debuff")
		self.debuff_vfx = "particles/units/heroes/guy/guy_dynamic_entry_armor_debuff_base.vpcf"
	end
end

function modifier_guy_dynamic_entry_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_guy_dynamic_entry_debuff:GetModifierPhysicalArmorBonus()
	return -1 * self.armor_debuff
end

function modifier_guy_dynamic_entry_debuff:GetEffectName()
	return self.debuff_vfx
end

function modifier_guy_dynamic_entry_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
