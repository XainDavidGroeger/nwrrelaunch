zabuza_water_dragon_bullet = zabuza_water_dragon_bullet or class({})

LinkLuaModifier("modifier_zabuza_slow", "scripts/vscripts/heroes/zabuza/modifiers/modifier_zabuza_slow.lua", LUA_MODIFIER_MOTION_NONE)

function zabuza_water_dragon_bullet:Precache( context )
    PrecacheResource( "particle",  "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf", context )
    PrecacheResource( "particle",  "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", context )
    PrecacheResource( "particle",  "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", context )

    PrecacheResource( "soundfile",  "soundevents/zabuza_dragon.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/heroes/zabuza/zabuza_dragon_talking.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/heroes/zabuza/zabuza_dragon_cast.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/heroes/zabuza/zabuza_dragon_fly.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/heroes/zabuza/zabuza_dragon_impact.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/heroes/zabuza/zabuza_dragon_precast.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", context )
end

function zabuza_water_dragon_bullet:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function zabuza_water_dragon_bullet:GetCastRange(location, target)
	return self:GetSpecialValueFor("range")
end

function zabuza_water_dragon_bullet:ProcsMagicStick()
	return true
end

function zabuza_water_dragon_bullet:OnSpellStart()
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")
	local caster_location = caster:GetAbsOrigin()
	local forwardVec = (target_point - caster_location):Normalized()
	self.target_point = target_point
	
	local wave_width = 450
	local wave_range = (target_point - caster_location):Length2D()
	local wave_location = caster_location
	
	-- Play sound
	EmitSoundOn("zabuza_dragon_talking", caster)
	EmitSoundOn("zabuza_dragon_precast", caster)
	
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

function zabuza_water_dragon_bullet:OnProjectileThink_ExtraData(location, data)
	if location.x  == self.target_point.x and location.y  == self.target_point.y then
		local caster = self:GetCaster()
		local target_point = self.target_point
		local radius = self:GetSpecialValueFor( "radius")
		local caster_location = caster:GetAbsOrigin()
		local radius = self:GetSpecialValueFor( "radius")
		local slow_base = self:GetSpecialValueFor( "ms_slow")
		local duration = self:GetSpecialValueFor( "duration")
		local slow_base_per_distance = self:GetSpecialValueFor("ms_slow_per_distance")
		local wave_range = (target_point - caster_location):Length2D()
		local distance_stack_count = wave_range / 150
		local damage = self:GetSpecialValueFor("damage")

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
	end
	
end

modifier_zabuza_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_zabuza_slow:IsHidden()
	return false
end

function modifier_zabuza_slow:IsDebuff()
	return true
end

function modifier_zabuza_slow:IsStunDebuff()
	return false
end

function modifier_zabuza_slow:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_zabuza_slow:OnCreated( kv )
	-- references
	self.caster = self:GetCaster()
	self.slow_percent = self:GetAbility():GetSpecialValueFor( "ms_slow_start" )
end

function modifier_zabuza_slow:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_zabuza_slow:OnRemoved()
end

function modifier_zabuza_slow:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_zabuza_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_zabuza_slow:GetModifierMoveSpeedBonus_Percentage()
	return (-1) * self:GetStackCount()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_zabuza_slow:CheckState()
	local state = {	}

	return state
end
