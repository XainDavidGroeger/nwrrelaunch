
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

function gaara_sabaku_taiso:OnSpellStart()

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

	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
	--	EffectName			= "",
		vSpawnOrigin		= casterOrigin,
		fDistance			= distance,
		fStartRadius		= start_radius,
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

	local particleName = "particles/units/heroes/gaara/new_ulti/wave.vpcf"
--	local particleName = "particles/units/heroes/gaara/wave.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, casterOrigin )
	ParticleManager:SetParticleControl( pfx, 1, direction * speed * 1.333 )
	ParticleManager:SetParticleControl( pfx, 3, Vector(0,0,0) )
	ParticleManager:SetParticleControl( pfx, 9, casterOrigin )

	caster:SetContextThink( DoUniqueString( "destroy_particle" ), function ()
		ParticleManager:DestroyParticle( pfx, false )
	end, distance / speed )


end


function gaara_sabaku_taiso:OnProjectileHit(hTarget, vLocation)

	if hTarget ~= nil then

		if hTarget:IsBuilding() then
			return
		end
	
		local knockbackModifierTable =
		{
			should_stun = 1,
			knockback_duration = 1.0,
			duration = 1.0,
			knockback_distance = 0,
			knockback_height = 0,
			center_x = hTarget:GetAbsOrigin().x,
			center_y = hTarget:GetAbsOrigin().y,
			center_z = hTarget:GetAbsOrigin().z + 300
		}
		hTarget:AddNewModifier( self.caster, nil, "modifier_knockback", knockbackModifierTable )
		
		hTarget:EmitSound("Hero_Brewmaster.ThunderClap")
		
		hTarget:EmitSound("Hero_PhantomAssassin.Dagger.Target")
	
		ApplyDamage({ victim =hTarget, attacker = self.caster, damage = self:GetAbilityDamage(), damage_type = DAMAGE_TYPE_MAGICAL })
	
		hTarget:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
	
		if hTarget:IsAlive() then
	
			local target_point = hTarget:GetAbsOrigin()
			-- Special Variables
			local duration = 1
			-- Dummy
			local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, self.caster, self.caster, self.caster:GetTeam())
	
			dummy:AddNewModifier(self.caster, nil, "modifier_phased", {})
			dummy:AddNewModifier(self.caster, self.ability,"modifier_gaara_cyclone",{target = hTarget})
	
			-- Timer to remove the dummy
			Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
		end

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
