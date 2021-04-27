guy_dynamic_entry_new = guy_dynamic_entry_new or class({})

function guy_dynamic_entry_new:GetAbilityTextureName()
	return "guy_dynamic_entry"
end

function guy_dynamic_entry_new:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_guy_5"):GetLevel() > 0 then
		castrangebonus = 550
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function guy_dynamic_entry_new:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("guy_entry")
	return true
end

function guy_dynamic_entry_new:OnSpellStart()

	self.target = self:GetCaster()
	self.target = self:GetCursorTarget()
	self.point = self.target:GetAbsOrigin()
	self.ability = self
	self.distance = 0
	
	add_physics(caster)

	local timer_tbl =
		{
			callback = dynamic_entry_periodic,
			point = caster:GetAbsOrigin()
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

function dynamic_entry_hit()
	local target = self..target
	local caster = self.caster
	local ability = self.ability
	local damage = ability:GetAbilityDamage()
	local particle_impact = "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf"

	ability:ApplyDataDrivenModifier(
			caster,
			target,
			keys.EntryModifier,
			{}
		)
		
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})		

	EmitSoundOn("Hero_Brewmaster.ThunderClap",caster)
	EmitSoundOn("Hero_Brewmaster.ThunderClap.Target",target)

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) 
		  ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
		  ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
		  
end

function dynamic_entry_periodic(gameEntity)
	local target = self.target
	local caster = self.caster

	local velocity = 2500

	local vector = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local direction = vector:Normalized()
	
	caster:SetPhysicsVelocity(direction * velocity)
	
	--Target reached
	if vector:Length2D() <= 2*caster:GetPaddedCollisionRadius() then
		dynamic_entry_hit()
		remove_physics(caster)
		return nil
	end
	
	local dist = caster:GetAbsOrigin() - self.point
	self.distance = self.distance + dist:Length2D()
	
	--Abort Distance / caster died / target died
	if ( self.distance >= 4000 ) or (not caster:IsAlive()) or (not target:IsAlive()) or (target:IsNull()) then
		remove_physics(caster)
		return nil
	end
	
	return 0.03
end
