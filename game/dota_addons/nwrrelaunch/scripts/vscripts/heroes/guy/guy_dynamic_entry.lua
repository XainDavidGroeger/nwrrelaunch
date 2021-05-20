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
	PrecacheResource("soundfile", "soundevents/heroes/guy/guy_dynamic_entry_cast.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/guy_entry.vsndevts", context)
end

function guy_dynamic_entry:GetCastRange(location, target)
	local castrangebonus = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_guy_5")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	castrangebonus = 550
	    end
	end
	if self:GetCaster():HasModifier("modifier_guy_seventh_gate") then
		return self:GetSpecialValueFor("cast_range_ulti") + castrangebonus
	else
		return self:GetSpecialValueFor("cast_range") + castrangebonus
	end
end

function guy_dynamic_entry:ProcsMagicStick()
    return true
end

function guy_dynamic_entry:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("guy_entry")
	return true
end

function guy_dynamic_entry:OnSpellStart()

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

	target:AddNewModifier(caster, ability, "modifier_guy_dynamic_entry_debuff", {duration = duration})
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})		

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
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.ms_debuff = self.ability:GetSpecialValueFor("ms_slow")
	self.ms_debuff_ulti = self.ability:GetSpecialValueFor("ms_slow_ulti")
end

function modifier_guy_dynamic_entry_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_guy_dynamic_entry_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self.caster:HasModifier("modifier_guy_seventh_gate") then
		return self.ms_debuff_ulti
	else 
		return self.ms_debuff
	end
end
