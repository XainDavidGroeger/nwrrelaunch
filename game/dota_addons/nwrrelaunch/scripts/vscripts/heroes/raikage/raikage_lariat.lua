
raikage_lariat = class({})
LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )


function raikage_lariat:Precache( context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sven.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/raikage/raikage_lariat_talking.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/raikage/raikage_lariat_impact.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/heroes/raikage/raikage_lariat_cast.vsndevts", context )

    PrecacheResource( "particle", "particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/raikage/lariat_aura.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/raikage/lariat_ground_parent.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/raikage/range_finder_lariat.vpcf", context )
end

function raikage_lariat:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

function raikage_lariat:CreateCustomIndicator()
	local particle_cast = "particles/units/heroes/raikage/range_finder_lariat.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function raikage_lariat:UpdateCustomIndicator( loc )
	-- get data
	local origin = self:GetCaster():GetAbsOrigin()
	local cast_range = self:GetSpecialValueFor("cast_range")
	local width = self:GetCaster():GetPaddedCollisionRadius()


	local distance = loc - self:GetCaster():GetAbsOrigin()
	local distance_2d = distance:Length2D()
	if distance_2d < cast_range then
		cast_range = distance_2d
	end

	-- get direction
	local direction = loc - origin
	direction.z = 0
	direction = direction:Normalized()

	ParticleManager:SetParticleControl( self.effect_cast, 0, origin )
	ParticleManager:SetParticleControl( self.effect_cast, 1, origin)
	ParticleManager:SetParticleControl( self.effect_cast, 2, origin + direction*cast_range)
	ParticleManager:SetParticleControl( self.effect_cast, 3, Vector(width, width, 0))
	ParticleManager:SetParticleControl( self.effect_cast, 4, Vector(0, 255, 0)) --Color (green by default)
	ParticleManager:SetParticleControl( self.effect_cast, 6, Vector(1,1,1)) --Enable color change
end

function raikage_lariat:DestroyCustomIndicator()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function raikage_lariat:CastFilterResultLocation(location)
	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( location )
		end
	end

	return UF_SUCCESS
end

function raikage_lariat:ProcsMagicStick()
    return true
end

function raikage_lariat:OnSpellStart()
	
	self:GetCaster():EmitSound("raikage_lariat_cast")

	self.ability = self
	self.caster = self:GetCaster()
	self.point = self:GetCursorPosition()
	self.velocity = self.ability:GetSpecialValueFor("speed")
	self.sound_impact = "Hero_Sven.StormBoltImpact"
	self.particle_impact = "particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf"

	self.caster:FadeGesture(ACT_DOTA_IDLE)
	self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

	self.caster.pfx = ParticleManager:CreateParticle("particles/units/heroes/raikage/lariat_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(self.caster.pfx, 0, Vector(1, 0, 0))

	self.caster:EmitSound("raikage_lariat_talking")

	self.origin = self.caster:GetAbsOrigin()
	local between = self.origin:Lerp(self.point, 0.5)

	local ground = ParticleManager:CreateParticle("particles/units/heroes/raikage/lariat_ground_parent.vpcf", PATTACH_ABSORIGIN, self.caster)
	ParticleManager:SetParticleControl(ground, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ground, 1, between)
	ParticleManager:SetParticleControl(ground, 2, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ground, 3, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ground, 4, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(ground, 5, self.point)
	ParticleManager:SetParticleControl(ground, 6, between)


	add_physics(self.caster)
	
	local timer_tbl =
		{
			callback = LariatPeriodic,
			keys = self,
			point = self.point,
			origin = self.caster:GetAbsOrigin(),
			ability = self.ability,
			caster = self.caster,
		}
	
	--Movement
	Timers:CreateTimer(timer_tbl)

end

function LariatPeriodic(gameEntity, keys)
	local caster = keys.caster
	local ability = keys.ability
	local velocity = ability:GetSpecialValueFor("speed")

	local vector = keys.point - caster:GetAbsOrigin()
	local direction = vector:Normalized()

	GridNav:DestroyTreesAroundPoint( caster:GetAbsOrigin(), 60, true)
	caster:SetPhysicsVelocity(direction * velocity)

	
	targetEntities = FindUnitsInRadius(caster:GetOpposingTeamNumber(), caster:GetAbsOrigin(), nil,
		3*caster:GetPaddedCollisionRadius(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	
	target = targetEntities[1]
	if(target) then	
		LariatHit(keys,target)
		remove_physics(caster)
		return nil
	end

	-- If the target reached the ground then remove physics
	if vector:Length2D() <= caster:GetPaddedCollisionRadius() then
		if( keys.origin ~= nil) then
			remove_physics(caster)
			caster:RemoveModifierByName("modifier_lariat_energy_shield")
			ParticleManager:DestroyParticle(keys.caster.pfx, false)
		else
			remove_physics(caster)
			caster:RemoveModifierByName("modifier_lariat_energy_shield")
			ParticleManager:DestroyParticle(keys.caster.pfx, false)
		end
	
		return nil
	end

	return 0.03
end

function LariatHit(keys,target)
	
	local caster = keys.caster
	local ability = keys.ability
	local velocity = ability:GetSpecialValueFor("speed")

	local vector = keys.point - caster:GetAbsOrigin()
	local direction = vector:Normalized()

	ParticleManager:DestroyParticle(caster.pfx, false)
	caster:RemoveModifierByName("modifier_lariat_energy_shield")

	caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_3)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3_END, 2)

	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local damage = ability:GetSpecialValueFor("damage")
	local abilityS = caster:FindAbilityByName("special_bonus_raikage_3")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	damage = damage + 220
	    end
	end

	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})

	-- Fire impact particle
	local enemy_loc = target:GetAbsOrigin()
	local impact_pfx = ParticleManager:CreateParticle(particle_impact, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(impact_pfx, 0, enemy_loc)
	ParticleManager:SetParticleControlEnt(impact_pfx, 3, target, PATTACH_ABSORIGIN, "attach_origin", enemy_loc, true)
	
	EmitSoundOn("raikage_lariat_impact", caster)

end





































--[[
	Author: Mognakor
	Date: December, 5/6th 2015.
]]
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

	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)

end






function fireGroundEffect( keys )




end