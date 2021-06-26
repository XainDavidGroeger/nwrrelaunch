
sai_super_beast_drawing = sai_super_beast_drawing or class({})
LinkLuaModifier( "modifier_super_beast_drawing_debuff", "heroes/sai/sai_super_beast_drawing.lua" ,LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )


function sai_super_beast_drawing:Precache(context)
	PrecacheResource("soundfile",  "soundevents/kisame_shark.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/heroes/kisame/kisame_shark_cast.vsndevts", context)
	PrecacheResource("particle",   "particles/units/heroes/kisame/shark.vpcf", context)
	PrecacheResource("particle",   "particles/units/heroes/kisame/range_finder_shark.vpcf", context)
end

function sai_super_beast_drawing:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

function sai_super_beast_drawing:GetAbilityTextureName()
	return "sai_super_beast_drawing"
end


function sai_super_beast_drawing:CreateCustomIndicator()
	local particle_cast = "particles/units/heroes/kisame/range_finder_shark.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function sai_super_beast_drawing:UpdateCustomIndicator( loc )
	-- get data
	local origin = self:GetCaster():GetAbsOrigin()
	local cast_range = self:GetSpecialValueFor("wave_range") + 150
	local width = self:GetSpecialValueFor("wave_aoe")

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

function sai_super_beast_drawing:DestroyCustomIndicator()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function sai_super_beast_drawing:CastFilterResultLocation(location)
	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( location )
		end
	end

	return UF_SUCCESS
end

function sai_super_beast_drawing:ProcsMagicStick()
	return true
end

function sai_super_beast_drawing:OnAbilityPhaseStart()

	self:GetCaster():EmitSound("kisame_shark")
	self:GetCaster():EmitSound("kisame_shark_cast")

	return true
end

function sai_super_beast_drawing:OnSpellStart()
	
	self.caster = self:GetCaster()
	self.caster_location = self.caster:GetAbsOrigin()
	self.ability = self
	self.target_point = self:GetCursorPosition()
	self.forwardVec = (self.target_point - self.caster_location):Normalized()

	-- Projectile variables
	self.wave_speed = self.ability:GetSpecialValueFor("projectile_speed")
	self.wave_width = self.ability:GetSpecialValueFor("wave_aoe")
	self.wave_range = self.ability:GetSpecialValueFor("wave_range")
	self.damage = self.ability:GetSpecialValueFor("damage")
	self.debuff_duration = self.ability:GetSpecialValueFor("root_duration")
	self.wave_location = self.caster_location
	self.wave_particle = "particles/units/heroes/sai/tiger.vpcf"
	-- Creating the projectile
	self.projectileTable =
	{
        bDeleteOnHit = true,
		Ability = self.ability,
		vSpawnOrigin = self.caster_location,
		vVelocity = Vector( self.forwardVec.x * self.wave_speed, self.forwardVec.y * self.wave_speed, 0 ),
		fDistance = self.wave_range,
		fStartRadius = self.wave_width,
		fEndRadius = self.wave_width,
		Source = self.caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	}

	-- Saving the projectile ID so that we can destroy it later
	self.projectile_id = ProjectileManager:CreateLinearProjectile( self.projectileTable )

    self.projectile_vfx = ParticleManager:CreateParticle(self.wave_particle, PATTACH_ABSORIGIN, self.caster)
	ParticleManager:SetParticleControl(self.projectile_vfx, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.projectile_vfx, 1, self.caster:GetForwardVector()*self.wave_speed)
	
end


function sai_super_beast_drawing:OnProjectileHit(hTarget, vLocation)

	if hTarget ~= nil then

		if hTarget:IsBuilding() then return end
		if hTarget:IsMagicImmune() then return end

		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_super_beast_drawing_debuff", {duration = self.debuff_duration})
		
		local damageTable = {
			victim = hTarget,
			attacker = self.caster,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage( damageTable )

        ParticleManager:DestroyParticle(self.projectile_vfx, true)
	    ParticleManager:ReleaseParticleIndex(self.projectile_vfx)
	end

end

modifier_super_beast_drawing_debuff = modifier_super_beast_drawing_debuff or class({})

function modifier_super_beast_drawing_debuff:GetEffectName() return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf" end
function modifier_super_beast_drawing_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_super_beast_drawing_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf" end

function modifier_super_beast_drawing_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end


