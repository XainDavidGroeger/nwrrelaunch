
gaara_sabaku_taiso = gaara_sabaku_taiso or class({})
LinkLuaModifier( "modifier_gaara_cyclone", "heroes/gaara/gaara_sabaku_taiso.lua" ,LUA_MODIFIER_MOTION_NONE )




function gaara_sabaku_taiso:GetAbilityTextureName()
	return "gaara_sabaku_taiso"
end

function gaara_sabaku_taiso:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_gaara_3"):GetLevel() > 0 then
		castrangebonus = 600
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end


function gaara_sabaku_taiso:OnAbilityPhaseStart()
	print("tesdasdsadsd")

	self:GetCaster():EmitSound("gaara_burial_cast")

	local direction = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
	direction = direction / direction:Length2D()

	self.build_up_particle = ParticleManager:CreateParticle( "particles/units/heroes/gaara/ulti/ulti_casting.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( self.build_up_particle, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.build_up_particle, 1, direction )
	ParticleManager:SetParticleControl( self.build_up_particle, 3, Vector(0,0,0) )
	ParticleManager:SetParticleControl( self.build_up_particle, 10, Vector(0,0,0) )

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
	if abilityS:IsTrained() then
		distance = distance + 600
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
	--	fExpireTime			= ,
		bDeleteOnHit		= false,
		vVelocity			= direction * speed,
		bProvidesVision		= false,
	--	iVisionRadius		= ,
	--	iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

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
	
		ApplyDamage({ victim =hTarget, attacker = self.caster, damage = self:GetAbilityDamage(), damage_type = DAMAGE_TYPE_MAGICAL })
	
		hTarget:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})

	end

end



modifier_gaara_cyclone = modifier_gaara_cyclone or class({})


function modifier_gaara_cyclone:OnCreated(keys)
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

	-- TODO
--	local cyclone = ParticleManager:CreateParticle("particles/units/heroes/yondaime/kunai_ground.vpcf", PATTACH_POINT_FOLLOW, keys.target) 
--	ParticleManager:SetParticleControlEnt(cyclone, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_origin", keys.target:GetAbsOrigin(), true)

--	self.sandking_epicenter = ParticleManager:CreateParticle("particles/items_fx/cyclone.vpcf", PATTACH_WORLDORIGIN, keys.target)
--	ParticleManager:SetParticleControlEnt(sandking_epicenter, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_origin", keys.target:GetAbsOrigin(), true)

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
