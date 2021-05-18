shikamaru_shadow_imitation_technique = class({})
LinkLuaModifier( "modifier_shadow_imitation", "heroes/shikamaru/shikamaru_shadow_imitation_technique.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
shikamaru_shadow_imitation_technique = shikamaru_shadow_imitation_technique or class({})

function shikamaru_shadow_imitation_technique:ProcsMagicStick()
	return true
end

function shikamaru_shadow_imitation_technique:OnSpellStart()
	
	self.caster = self:GetCaster()
	self.caster_location = self.caster:GetAbsOrigin()
	self.ability = self
	self.target_point = self:GetCursorPosition()
	self.forwardVec = (self.target_point - self.caster_location):Normalized()

	-- Projectile variables
	self.shadow_speed = self.ability:GetSpecialValueFor("shadow_speed")
	self.shadow_duration = self.ability:GetSpecialValueFor("shadow_duration")
	self.shadow_width = self.ability:GetSpecialValueFor("shadow_width")
	self.shadow_range = self.ability:GetSpecialValueFor("shadow_range")
	self.shadow_location = self.caster_location
	self.wave_particle = "particles/units/heroes/kisame/shark.vpcf"
	-- Creating the projectile
	self.projectileTable =
	{
		EffectName = self.wave_particle,
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

end


function shikamaru_shadow_imitation_technique:OnProjectileHit(hTarget, vLocation)

	if hTarget ~= nil then
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_shadow_imitation", {duration = 10})
	end

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

	--Physics:Unit(self.parent)
	--self.parent:PreventDI(true)
	--self.parent:SetAutoUnstuck(false)
	--self.parent:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	--self.parent:FollowNavMesh(false)
	self.parent:StartGesture(ACT_DOTA_RUN)


	if not IsServer() then return end
	-- ability properties

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
		self.parent:SetAbsOrigin(new_pos);
		self.old_shikamaru_postion = new_shikamaru
	else
		
	end

	if old_shikamaru ~= new_shikamaru then
		if self.gesture == ACT_DOTA_IDLE then
		--	self.parent:RemoveGesture(ACT_DOTA_IDLE)
		--	self.parent:StartGesture(ACT_DOTA_RUN)
		--	self.gesture = ACT_DOTA_RUN
		end
		
	else 
		if self.gesture == ACT_DOTA_RUN then
		--	self.parent:RemoveGesture(ACT_DOTA_RUN)
		--	self.parent:StartGesture(ACT_DOTA_IDLE)
		--	self.gesture = ACT_DOTA_IDLE
		end
	end
	self.direction = direction
end

function modifier_shadow_imitation:OnRemoved()
end

function modifier_shadow_imitation:OnDestroy()
	if not IsServer() then return end
	self.parent:RemoveGesture(ACT_DOTA_RUN)
	self.parent:RemoveGesture(ACT_DOTA_IDLE)

	--self.parent:SetPhysicsAcceleration(Vector(0,0,0))
	--self.parent:SetPhysicsVelocity(Vector(0,0,0))
	--self.parent:OnPhysicsFrame(nil)
	--self.parent:PreventDI(false)
	--self.parent:SetAutoUnstuck(true)
	--self.parent:FollowNavMesh(true)
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_shadow_imitation:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}

	return state
end

