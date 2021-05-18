zabuza_water_dragon_bullet = zabuza_water_dragon_bullet or class({})

LinkLuaModifier("modifier_zabuza_slow", "scripts/vscripts/heroes/zabuza/zabuza_water_dragon_bullet.lua", LUA_MODIFIER_MOTION_NONE)

function zabuza_water_dragon_bullet:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function zabuza_water_dragon_bullet:GetCastRange(location, target)
	return self:GetSpecialValueFor("range")
end

function zabuza_water_dragon_bullet:ProcsMagicStick()
	return true
end

function zabuza_water_dragon_bullet:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("zabuza_dragon_talking")
	self:GetCaster():EmitSound("zabuza_dragon_precast")
	return true
end


function zabuza_water_dragon_bullet:OnSpellStart()
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	local caster_location = caster:GetAbsOrigin()
	local forwardVec = (target_point - caster_location):Normalized()
	
	local wave_width = 450
	local wave_range = (target_point - caster_location):Length2D()
	local wave_location = caster_location
	
	local radius = self:GetSpecialValueFor( "radius")
	local slow_base = self:GetSpecialValueFor( "ms_slow")
	local duration = self:GetSpecialValueFor( "duration")
	local slow_base_per_distance = self:GetSpecialValueFor("ms_slow_per_distance")
	local distance_stack_count = wave_range / 150

	
	local wave_speed = self:GetSpecialValueFor("dragon_speed")

	local ability1 = caster:FindAbilityByName("special_bonus_zabuza_1")
	if ability1 ~= nil then
	    if ability1:IsTrained() then
	    	wave_speed = wave_speed + 300
	    end
	end
	
	local projectile =
	{
		Target 				= target_point,
		Source 				= caster,
		Ability 			= self,
		EffectName 			= "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf",
		iMoveSpeed			= wave_speed,
		vSpawnOrigin 		= caster:GetAbsOrigin(),
		vVelocity = Vector( forwardVec.x * wave_speed, forwardVec.y * wave_speed, 0 ),
		fDistance = wave_range,
		fStartRadius = wave_width,
		fEndRadius = wave_width,
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 10,
		bProvidesVision 	= true,
		iVisionRadius 		= 0,
		iVisionTeamNumber 	= caster:GetTeamNumber(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		ExtraData			= {duration = duration}
	}
	
	projectile_id = ProjectileManager:CreateLinearProjectile(projectile)
	
	EmitSoundOn("zabuza_dragon_cast", caster)
	caster:EmitSound("zabuza_dragon_fly")
	
	--local bubble_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	--ParticleManager:SetParticleControl(bubble_particle, 0, target_point)
	
	Timers:CreateTimer(1, function ()
	    local enemies = FindUnitsInRadius(
	    	caster:GetTeamNumber(),	-- int, your team number
	    	target_point,	-- point, center point
	    	nil,	-- handle, cacheUnit. (not known)
	    	radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
	    	DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
	    	DOTA_UNIT_TARGET_HERO,	-- int, type filter
	    	0,	-- int, flag filter
	    	FIND_ANY_ORDER,	-- int, order filter
	    	false	-- bool, can grow cache
	    )
        
	    caster:StopSound("zabuza_dragon_fly")
        
	    local stackcount = slow_base + (distance_stack_count * slow_base_per_distance)
	    stackcount = stackcount * -1
	    if enemies then
	    	for _,target in pairs(enemies) do
			    target:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_zabuza_slow", -- modifier name
                { duration = duration } -- kv
                )
	    		target:SetModifierStackCount("modifier_zabuza_slow", self, stackcount)
				
				ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	    	end
	    end
        
		EmitSoundOnLocationWithCaster(target_point, "zabuza_dragon_impact", caster)
		
		local dragon_end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_POINT, caster)
	    ParticleManager:SetParticleControl(dragon_end_particle, 0, target_point)
	end)
end

function zabuza_water_dragon_bullet:OnProjectileHit_ExtraData(target, location, ExtraData)
	if IsServer() then
		local caster = self:GetCaster()

		caster:RemoveNoDraw()
        
		if target ~= nil then
		    target:AddNewModifier(caster, self, "modifier_zabuza_slow", {duration = ExtraData.duration})
		end
	end
end