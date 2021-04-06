
guy_dynamic_entry = guy_dynamic_entry or class({})

LinkLuaModifier("modifier_guy_dynamic_entry_miss", "heroes/guy/dynamic_entry.lua", LUA_MODIFIER_MOTION_NONE)

function guy_dynamic_entry:GetAbilityTextureName()
	return "guy_dynamic_entry"
end

function guy_dynamic_entry:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_guy_5"):GetLevel() > 0 then
		castrangebonus = 550
	end
	return self:GetSpecialValueFor("cast_range") + castrangebonus
end

function guy_dynamic_entry:OnSpellStart()

	self.caster = self:GetCaster()
	self.duration = self:GetSpecialValueFor("duration")
	self.target = self:GetCursorTarget()
	self.distance = 0
	
	Physics:Unit(self.caster)

	self.caster:PreventDI(true)
	self.caster:SetAutoUnstuck(false)
	self.caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	self.caster:FollowNavMesh(false)	

	local timer_tbl =
		{
			callback = dynamic_entry_periodic,
			target = self.target,
			caster = self.caster,
			duration = self.duration,
			ability = self,
			damage = self:GetAbilityDamage(),
			distance = 0,
			point = self.caster:GetAbsOrigin()
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

function dynamic_entry_hit(keys)

	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local duration = keys.duration
	local damage = keys.ability:GetAbilityDamage()
	local particle_impact = "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf"
	local modifier = "modifier_guy_dynamic_entry_miss"

	target:AddNewModifier(caster, ability, modifier, {duration = duration})
		
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = keys.ability:GetAbilityDamageType()})		

	EmitSoundOn("Hero_Brewmaster.ThunderClap",caster)
	EmitSoundOn("Hero_Brewmaster.ThunderClap.Target",target)

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) 
		  ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
		  ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
		  
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
		dynamic_entry_hit(keys)
	
		remove_physics(caster)
		return nil
	end
	
	local dist = caster:GetAbsOrigin() - keys.point
	keys.distance = keys.distance + dist:Length2D()
	
	--Abort Distance / caster died / target died
	if ( keys.distance >= 9000 ) or (not caster:IsAlive()) or (not target:IsAlive()) or (target:IsNull()) then
		remove_physics(caster)
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), false )
		return nil
	end
	

	return 0.03
end

modifier_guy_dynamic_entry_miss = modifier_guy_dynamic_entry_miss or class({})

function modifier_guy_dynamic_entry_miss:IsHidden() return false end
function modifier_guy_dynamic_entry_miss:IsPurgable() return true end
function modifier_guy_dynamic_entry_miss:IsDebuff() return true end

function modifier_guy_dynamic_entry_miss:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

	-- Ability specials
	self.miss_chance = self.ability:GetSpecialValueFor("miss_chance")
end

function modifier_guy_dynamic_entry_miss:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MISS_PERCENTAGE}

	return decFuncs
end

function modifier_guy_dynamic_entry_miss:GetModifierMiss_Percentage()
	local value = 0
	if self.caster:FindAbilityByName("special_bonus_guy_1"):GetLevel() > 0 then
		value = 35
	end
	return self.miss_chance + value
end
