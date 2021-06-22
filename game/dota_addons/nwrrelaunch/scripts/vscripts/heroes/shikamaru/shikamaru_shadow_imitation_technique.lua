shikamaru_shadow_imitation_technique = class({})
LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )

LinkLuaModifier( "modifier_shadow_imitation", "heroes/shikamaru/shikamaru_shadow_imitation_technique.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_imitation_caster", "heroes/shikamaru/shikamaru_shadow_imitation_technique.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
shikamaru_shadow_imitation_technique = shikamaru_shadow_imitation_technique or class({})

function shikamaru_shadow_imitation_technique:Precache( context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_shaman_shackle.vpcf" , context )
    PrecacheResource( "particle", "particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/shikamaru/shikamaru_shackle_aladeen.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/shikamaru/shikamaru_aladeen_rope_glow.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/shikamaru/shikamaru_spectral_test_tracking.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/raikage/range_finder_lariat.vpcf", context )

    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/shikamaru/shikamaru_hold_cast.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/heroes/shikamaru/shikamaru_hold_impact.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/heroes/shikamaru/shikamaru_hold_talking.vsndevts", context )

end

function shikamaru_shadow_imitation_technique:ProcsMagicStick()
	return true
end

function shikamaru_shadow_imitation_technique:GetCooldown(iLevel)
	local cdrecution = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_shikamaru_2")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	cdrecution = 3
	    end
	end
	return self.BaseClass.GetCooldown(self, iLevel) - cdrecution
end


function shikamaru_shadow_imitation_technique:CreateCustomIndicator()
	local particle_cast = "particles/units/heroes/raikage/range_finder_lariat.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function shikamaru_shadow_imitation_technique:UpdateCustomIndicator( loc )
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

function shikamaru_shadow_imitation_technique:DestroyCustomIndicator()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function shikamaru_shadow_imitation_technique:CastFilterResultLocation(location)
	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( location )
		end
	end

	return UF_SUCCESS
end

function shikamaru_shadow_imitation_technique:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("shikamaru_hold_cast")
	self:GetCaster():EmitSound("shikamaru_hold_talking")
	return true
end

function shikamaru_shadow_imitation_technique:OnSpellStart()
	
	self.caster = self:GetCaster()
	self.caster_location = self.caster:GetAbsOrigin()
	self.ability = self
	self.target_point = self:GetCursorPosition()
	self.forwardVec = (self.target_point - self.caster_location):Normalized()

	self.caster:AddNewModifier(self.caster, self.ability, "modifier_shadow_imitation_caster", {})
	self.caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)

	-- Projectile variables
	self.shadow_speed = self.ability:GetSpecialValueFor("shadow_speed")
	self.shadow_duration = self.ability:GetSpecialValueFor("shadow_duration") + self.caster:FindTalentValue("special_bonus_shikamaru_4")
	print(self.shadow_duration)

	self.shadow_width = self.ability:GetSpecialValueFor("shadow_width")
	self.shadow_range = self.ability:GetSpecialValueFor("shadow_range")
	self.shadow_location = self.caster_location
	self.wave_particle = "particles/units/heroes/shikamaru/shikamaru_shadow_imitation.vpcf"
	-- Creating the projectile
	self.projectileTable =
	{
		-- EffectName = self.wave_particle,
		Ability = self.ability,
		vSpawnOrigin = self.caster_location,
		vVelocity = Vector( self.forwardVec.x * self.shadow_speed, self.forwardVec.y * self.shadow_speed, 0 ),
		fDistance = self.shadow_range,
		fStartRadius = self.shadow_width,
		fEndRadius = self.shadow_width,
		Source = self.caster,
		bDeleteOnHit = true,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO
	}
	-- Saving the projectile ID so that we can destroy it later
	self.projectile_id = ProjectileManager:CreateLinearProjectile( self.projectileTable )

	self.projectile_vfx = ParticleManager:CreateParticle(self.wave_particle, PATTACH_ABSORIGIN, self.caster)
	ParticleManager:SetParticleControl(self.projectile_vfx, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.projectile_vfx, 1, self.caster:GetForwardVector()*self.shadow_speed)


end

function shikamaru_shadow_imitation_technique:OnProjectileThink(location)
	ParticleManager:SetParticleControl(self.projectile_vfx, 3, location)
end


function shikamaru_shadow_imitation_technique:OnProjectileHit(hTarget, vLocation)
	self.caster:RemoveModifierByName("modifier_shadow_imitation_caster")
	self.caster:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
	if hTarget ~= nil and hTarget:IsMagicImmune() == false then
		hTarget:Stop()
		hTarget:EmitSound("shikamaru_hold_impact")
		if hTarget:HasModifier("modifier_flash_bomb_debuff") then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_shadow_imitation", {duration = (self.shadow_duration + 0.5)})
		else
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_shadow_imitation", {duration = self.shadow_duration})
		end
	end

	ParticleManager:DestroyParticle(self.projectile_vfx, true)
	ParticleManager:ReleaseParticleIndex(self.projectile_vfx)

	return true
end

modifier_shadow_imitation = modifier_shadow_imitation or class({})

-- Classifications
function modifier_shadow_imitation:IsHidden()
	return false
end

function modifier_shadow_imitation:IsDebuff()
	return true
end

function modifier_shadow_imitation:IsStunDebuff()
	return true
end

function modifier_shadow_imitation:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_shadow_imitation:OnCreated( kv )
	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.team = self:GetCaster():GetTeamNumber()
	self.old_shikamaru_postion = self:GetCaster():GetAbsOrigin()
	self.direction = Vector(0,0,0)
	self.gesture = ACT_DOTA_IDLE


	-- ParticleManager:SetParticleControl(self.status_vfx, 0, self.caster:GetAbsOrigin())



	if not IsServer() then return end
	-- ability properties
	-- self.parent:StartGesture(ACT_DOTA_RUN)
	self.parent:Stop()
	self.status_vfx = ParticleManager:CreateParticle("particles/units/heroes/shikamaru/shikamaru_shadow_imitation_status_rope.vpcf", 
	PATTACH_ABSORIGIN, self.caster)
	ParticleManager:SetParticleControl(self.status_vfx, 1, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.status_vfx, 3, self.parent:GetAbsOrigin())

	self:StartIntervalThink(FrameTime())
end

function modifier_shadow_imitation:OnRefresh( kv )
	
end

function modifier_shadow_imitation:OnIntervalThink()

	-- get data
	local current_position = self:GetParent():GetAbsOrigin()
	local old_shikamaru = self.old_shikamaru_postion
	local new_shikamaru = self:GetCaster():GetAbsOrigin()

	local vector = new_shikamaru - old_shikamaru
	local direction = vector:Normalized()

	if self.parent:GetForwardVector() ~= self.caster:GetForwardVector() then
		self.parent:SetForwardVector(self.caster:GetForwardVector())
	end

	if self.caster:IsMoving() then
		self.direction = direction
		self.direction.z = 0
		local new_pos = (self.parent:GetAbsOrigin() + self.caster:GetForwardVector() * self.caster:GetMoveSpeedModifier(self.caster:GetBaseMoveSpeed(), false) * FrameTime())
		new_pos = GetGroundPosition(new_pos, self.parent)
		self.parent:SetAbsOrigin(new_pos);
		self.old_shikamaru_postion = new_shikamaru
		if self.gesture == ACT_DOTA_IDLE then
			self.parent:RemoveGesture(ACT_DOTA_IDLE)
			self.parent:StartGesture(ACT_DOTA_RUN)
			self.gesture = ACT_DOTA_RUN
	end
	else
		if self.gesture == ACT_DOTA_RUN then
				self.parent:RemoveGesture(ACT_DOTA_RUN)
				self.parent:StartGesture(ACT_DOTA_IDLE)
				self.gesture = ACT_DOTA_IDLE
		end
	end

	self.direction = direction

	-- ParticleManager:SetParticleControl(self.status_vfx, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.status_vfx, 1, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.status_vfx, 3, self.parent:GetAbsOrigin())
end

function modifier_shadow_imitation:OnRemoved()
end

function modifier_shadow_imitation:OnDestroy()
	ParticleManager:DestroyParticle(self.status_vfx, true)
	ParticleManager:ReleaseParticleIndex(self.status_vfx)
	
	if not IsServer() then return end
	self.parent:FadeGesture(self.gesture)
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_shadow_imitation:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_PROVIDES_VISION] = true,
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end


modifier_shadow_imitation_caster = modifier_shadow_imitation_caster or class({})

function modifier_shadow_imitation_caster:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end

