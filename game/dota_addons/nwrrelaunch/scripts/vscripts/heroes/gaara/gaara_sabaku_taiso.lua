
gaara_sabaku_taiso = gaara_sabaku_taiso or class({})
LinkLuaModifier( "modifier_gaara_cyclone", "heroes/gaara/gaara_sabaku_taiso.lua" ,LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )

function gaara_sabaku_taiso:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/gaara/ulti/ulti_core.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/gaara/ulti/ulti_casting.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/gaara/ulti/range_finder_ulti.vpcf"	, context)
	PrecacheResource("soundfile", "soundevents/heroes/gaara/gaara_burial_cast.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/heroes/gaara/gaara_burial_talking.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/heroes/gaara/gaara_burial_projectile.vsndevts", context)
end

function gaara_sabaku_taiso:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

function gaara_sabaku_taiso:GetAbilityTextureName()
	return "gaara_sabaku_taiso"
end

function gaara_sabaku_taiso:GetCastRange(location, target)
	local castrangebonus = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_gaara_3")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	castrangebonus = 99999
	    end
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end


function gaara_sabaku_taiso:CreateCustomIndicator()
	local particle_cast = "particles/units/heroes/gaara/ulti/range_finder_ulti.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function gaara_sabaku_taiso:UpdateCustomIndicator( loc )
	-- get data
	local origin = self:GetCaster():GetAbsOrigin()
	local cast_range = self:GetCastRange(loc, nil)
	local width = self:GetSpecialValueFor("end_radius")

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

function gaara_sabaku_taiso:DestroyCustomIndicator()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function gaara_sabaku_taiso:CastFilterResultLocation(location)
	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( location )
		end
	end

	return UF_SUCCESS
end

function gaara_sabaku_taiso:ProcsMagicStick()
    return true
end

function gaara_sabaku_taiso:OnAbilityPhaseStart()

	self:GetCaster():EmitSound("gaara_burial_cast")
	self:GetCaster():EmitSound("gaara_burial_talking")

	local direction = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
	direction = direction / direction:Length2D()

	self.build_up_particle = ParticleManager:CreateParticle( "particles/units/heroes/gaara/ulti/ulti_casting.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( self.build_up_particle, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.build_up_particle, 1, direction )
	ParticleManager:SetParticleControl( self.build_up_particle, 3, Vector(0,0,0) )
	ParticleManager:SetParticleControl( self.build_up_particle, 10, Vector(0,0,0) )

	Timers:CreateTimer( 1.15, function()
		ParticleManager:DestroyParticle( self.build_up_particle, true )
	end)

	return true
end

function gaara_sabaku_taiso:OnSpellStart()
	
	Timers:CreateTimer( 0.15, function()
		ParticleManager:DestroyParticle( self.build_up_particle, true )
	end)


	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	local ability = self
	local casterOrigin = caster:GetAbsOrigin()
	local targetPos = self:GetCursorPosition()
	local direction = targetPos - casterOrigin
	direction = direction / direction:Length2D()

	local start_radius = self:GetSpecialValueFor("start_radius")
	local end_radius = self:GetSpecialValueFor("end_radius")
	local speed = self:GetSpecialValueFor("speed")

	local distance =  self:GetSpecialValueFor("range")

	local abilityS = caster:FindAbilityByName("special_bonus_gaara_3")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	distance = distance + 99999
	    end
	end

	local particleName = "particles/units/heroes/gaara/ulti/ulti_core.vpcf"

	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= particleName,
		vSpawnOrigin		= casterOrigin,
		fDistance			= distance,
		fStartRadius		= end_radius,
		fEndRadius			= end_radius,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	--	fExpireTime			= ,
		bDeleteOnHit		= false,
		vVelocity			= direction * speed,
		bProvidesVision		= false,
	--	iVisionRadius		= ,
	--	iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	self:GetCaster():EmitSound("gaara_burial_projectile")

end


function gaara_sabaku_taiso:OnProjectileHit(hTarget, vLocation)

	if hTarget ~= nil then

		if hTarget:IsBuilding() then
			return
		end
	
		-- Knockback enemies up and towards the target point
		local knockbackProperties =
		{
			center_x = hTarget:GetAbsOrigin().x,
			center_y = hTarget:GetAbsOrigin().y,
			center_z = hTarget:GetAbsOrigin().z,
			duration = 0.3,
			knockback_duration = 0.3,
			knockback_distance = 0,
			knockback_height = 150
		}

		hTarget:AddNewModifier(hTarget, nil, "modifier_knockback", knockbackProperties)	
		hTarget:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})

		if not hTarget:IsMagicImmune() then
			ApplyDamage({ 
				victim =hTarget, 
				attacker = self.caster, 
				damage = self:GetAbilityDamage(), 
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self.ability
			})
		end
	end

end



modifier_gaara_cyclone = modifier_gaara_cyclone or class({})


function modifier_gaara_cyclone:OnCreated(keys)
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
end


function modifier_gaara_cyclone:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}

	return state
end
