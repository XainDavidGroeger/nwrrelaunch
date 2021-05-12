shikamaru_shadow_imitation_technique = class({})
LinkLuaModifier( "modifier_shadow_imitation", "heroes/shikamaru/shikamaru_shadow_imitation_technique.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function shikamaru_shadow_imitation_technique:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	return true
end

--------------------------------------------------------------------------------

function shikamaru_shadow_imitation_technique:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

--------------------------------------------------------------------------------

function shikamaru_shadow_imitation_technique:OnSpellStart()
	self.bChainAttached = false
	if self.hVictim ~= nil then
		self.hVictim:InterruptMotionControllers( true )
	end

	self.speed = self:GetSpecialValueFor( "projectile_speed" )
	self.width = self:GetSpecialValueFor( "projectile_width" )
	self.distance = self:GetSpecialValueFor( "cast_range" )

	self.followthrough_constant = self:GetSpecialValueFor( "followthrough_constant" )

	self.vision_radius = self:GetSpecialValueFor( "vision_radius" )  
	self.vision_duration = self:GetSpecialValueFor( "vision_duration" )  
	

	self.vStartPosition = self:GetCaster():GetOrigin()
	self.vProjectileLocation = vStartPosition

	local vDirection = self:GetCursorPosition() - self.vStartPosition
	vDirection.z = 0.0

	local vDirection = ( vDirection:Normalized() ) * self.distance
	self.vTargetPosition = self.vStartPosition + vDirection

	local flFollowthroughDuration = ( self.distance / self.speed * self.followthrough_constant )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", { duration = flFollowthroughDuration } )

	self.vHookOffset = Vector( 0, 0, 96 )
	local vHookTarget = self.vTargetPosition + self.vHookOffset
	local vKillswitch = Vector( ( ( self.distance / self.speed ) * 2 ), 0, 0 )

	self.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( self.nChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_right_hand", self:GetCaster():GetOrigin() + self.vHookOffset, true )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 1, vHookTarget )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 2, Vector( self.speed, self.distance, self.width ) )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, vKillswitch )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

	EmitSoundOn( "anko_hand_cast", self:GetCaster() )

	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = vDirection:Normalized() * self.speed,
		fDistance = self.distance,
		fStartRadius = self.width ,
		fEndRadius = self.width ,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	}

	ProjectileManager:CreateLinearProjectile( info )

	self.bRetracting = false
	self.hVictim = nil
	self.bDiedInHook = false

end

--------------------------------------------------------------------------------

function shikamaru_shadow_imitation_technique:OnProjectileHit( hTarget, vLocation )
	if hTarget == self:GetCaster() then
		return false
	end

	if hTarget ~= nil and ( not ( hTarget:IsCreep() or hTarget:IsConsideredHero() ) ) then
		Msg( "Target was invalid")
		return false
	end

	if hTarget ~= nil then
		EmitSoundOn( "anko_hand_impact", hTarget )

		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_shadow_imitation", nil )
		
		if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			
			if not hTarget:IsAlive() then
				self.bDiedInHook = true
			end

			if not hTarget:IsMagicImmune() then
				hTarget:Interrupt()
			end
	
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end

		AddFOWViewer( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self.vision_radius, self.vision_duration, false )
	end

	return true
end

--------------------------------------------------------------------------------

function shikamaru_shadow_imitation_technique:OnProjectileThink( vLocation )
	self.vProjectileLocation = vLocation
end

--------------------------------------------------------------------------------

function shikamaru_shadow_imitation_technique:OnOwnerDied()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
	self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

--------------------------------------------------------------------------------

modifier_shadow_imitation = modifier_shadow_imitation or class({})

function modifier_shadow_imitation:DeclareFunctions() return {
} end

function modifier_shadow_imitation:OnCreated()
		-- references
		self.caster = self:GetCaster()
		local abilityS = self.caster:FindAbilityByName("special_bonus_kisame_5")
		self.armor_debuff = self:GetAbility():GetSpecialValueFor( "armor_debuff" )
		
		if abilityS:GetLevel() > 0 then
			self.armor_debuff = self.armor_debuff - 5
		end
end
