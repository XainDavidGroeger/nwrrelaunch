
kisame_suikodan_no_jutsu = kisame_suikodan_no_jutsu or class({})
LinkLuaModifier( "modifier_suikodan_no_jutsu_debuff", "heroes/kisame/kisame_suikodan_no_jutsu.lua" ,LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )



function kisame_suikodan_no_jutsu:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

function kisame_suikodan_no_jutsu:GetAbilityTextureName()
	return "kisame_suikodan_no_jutsu"
end


function kisame_suikodan_no_jutsu:CreateCustomIndicator()
	local particle_cast = "particles/units/heroes/kisame/range_finder_shark.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function kisame_suikodan_no_jutsu:UpdateCustomIndicator( loc )
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

function kisame_suikodan_no_jutsu:DestroyCustomIndicator()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function kisame_suikodan_no_jutsu:CastFilterResultLocation(location)
	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( location )
		end
	end

	return UF_SUCCESS
end


function kisame_suikodan_no_jutsu:OnAbilityPhaseStart()

	self:GetCaster():EmitSound("kisame_shark")
	self:GetCaster():EmitSound("kisame_shark_cast")

	return true
end

function kisame_suikodan_no_jutsu:OnSpellStart()
	
	self.caster = self:GetCaster()
	self.caster_location = self.caster:GetAbsOrigin()
	self.ability = self
	self.target_point = self:GetCursorPosition()
	self.forwardVec = (self.target_point - self.caster_location):Normalized()

	-- Projectile variables
	self.wave_speed = self.ability:GetSpecialValueFor("wave_speed")
	self.wave_width = self.ability:GetSpecialValueFor("wave_aoe")
	self.wave_range = self.ability:GetSpecialValueFor("wave_range")
	self.damage = self.ability:GetSpecialValueFor("damage")
	self.debuff_duration = self.ability:GetSpecialValueFor("slow_duration")
	self.wave_location = self.caster_location
	self.wave_particle = "particles/units/heroes/kisame/shark.vpcf"
	-- Creating the projectile
	self.projectileTable =
	{
		EffectName = self.wave_particle,
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
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	}
	-- Saving the projectile ID so that we can destroy it later
	self.projectile_id = ProjectileManager:CreateLinearProjectile( self.projectileTable )
	

	-- Timer to provide vision
	Timers:CreateTimer( function()
		-- Calculating the distance traveled
		self.wave_location = self.wave_location + self.forwardVec * (self.wave_speed * 1/30)

		-- Reveal the area after the projectile passes through it


		self.distance = (self.wave_location - self.caster_location):Length2D()

		-- Checking if we traveled far enough, if yes then destroy the timer
		if self.distance >= self.wave_range then
			return nil
		else
			return 1/30
		end
	end)

end


function kisame_suikodan_no_jutsu:OnProjectileHit(hTarget, vLocation)

	if hTarget ~= nil then

		if hTarget:IsBuilding() then
			return
		end

		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_suikodan_no_jutsu_debuff", {duration = self.debuff_duration})
		
		local ability1 = self.caster:FindAbilityByName("special_bonus_kisame_1")
		if ability1 ~= nil then
		    if ability1:IsTrained() then
		    	self.damage = self.damage + 90
		    end
		end
	
		local damageTable = {
			victim = hTarget,
			attacker = self.caster,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage( damageTable )
	end

end

modifier_suikodan_no_jutsu_debuff = modifier_suikodan_no_jutsu_debuff or class({})

function modifier_suikodan_no_jutsu_debuff:GetEffectName() return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf" end
function modifier_suikodan_no_jutsu_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_suikodan_no_jutsu_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf" end

function modifier_suikodan_no_jutsu_debuff:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,

} end

function modifier_suikodan_no_jutsu_debuff:OnCreated()
		-- references
		self.caster = self:GetCaster()
		local abilityS = self.caster:FindAbilityByName("special_bonus_kisame_5")
		self.armor_debuff = self:GetAbility():GetSpecialValueFor( "armor_debuff" )
		
		if abilityS ~= nil then
		    if abilityS:GetLevel() > 0 then
		    	self.armor_debuff = self.armor_debuff - 5
		    end
		end
end

function modifier_suikodan_no_jutsu_debuff:GetModifierPhysicalArmorBonus()
	return self.armor_debuff
end

function modifier_suikodan_no_jutsu_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_slow_percentage")
end
