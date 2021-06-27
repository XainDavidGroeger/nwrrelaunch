--[[
Ability checklist (erase if done/checked):
- Active
Unleashes rat drawings to hunt down the nearest enemy heroes within range, including those in the fog of war. Upon reaching a target, the rats deal damage and slow the unit while also granting vision for a short duration.

x Cast Animation - 0.3 Seconds
x Search Radius - 1800
x Number of Targets - 2 (3)
x Damage per Snake - 90/155/220/285
x Move Speed Slow - 100%
x Slow Duration - 0.4/0.5/0.6/0.7 Seconds
x Vision Duration - 2 (4) seconds
x Mana Cost - 80/90/100/110
x Cooldown - 11/10/9/8 Seconds
x (Rat Travel Speed - 700)
]]
-------------------------------------------------------------------------
sai_rat_reconnaissance = class({})
LinkLuaModifier( "modifier_sai_rat_reconnaissance_debuff", "heroes/sai/sai_rat_reconnaissance", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------
--init not working
function sai_rat_reconnaissance:OnCreated(kv)
	-- NOT WORKING self.debuff_duration= self:GetSpecialValueFor("debuff_duration")
end
-- Ability Start
function sai_rat_reconnaissance:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")	
	local targets = self:GetSpecialValueFor("targets")
	if caster:HasScepter() then
		targets = self:GetSpecialValueFor("targets_scepter")
	end
	local projectile_name = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
	local projectile_speed = self:GetSpecialValueFor("speed")

	-- find enemies
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- create projectile for each enemy
	local info = {
		Source = caster,
		-- Target = target,
		Ability = self,
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
		ExtraData = {
			damage = damage,
		}
	}
	for i=1,math.min(targets,#enemies) do
		info.Target = enemies[i]
		ProjectileManager:CreateTrackingProjectile( info )
	end

	-- effects
	if #enemies<1 then
		self:PlayEffects2()
	else
		local sound_cast = "Hero_Tinker.Heat-Seeking_Missile"
		EmitSoundOn( sound_cast, caster )
	end
end
--------------------------------------------------------------------------------
-- Projectile
function sai_rat_reconnaissance:OnProjectileHit_ExtraData( target, location, extraData )
	local debuff_duration= self:GetSpecialValueFor("debuff_duration")
	if IsServer() then
		-- Apply damage 
		local damage = {
			victim = target,
			attacker = self:GetCaster(),
			damage = extraData.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}
		ApplyDamage( damage )
		--Apply debuff
		target:AddNewModifier(self:GetCaster(), self, "modifier_sai_rat_reconnaissance_debuff", {duration = debuff_duration})
		-- effects
		self:PlayEffects1( target )
	end
end

---------------
modifier_sai_rat_reconnaissance_debuff= class({})


-- Classifications defaults required
function modifier_sai_rat_reconnaissance_debuff:IsHidden() --shown or not as debuff
	return false
end

function modifier_sai_rat_reconnaissance_debuff:IsDebuff() --type of
	return true
end

function modifier_sai_rat_reconnaissance_debuff:IsStunDebuff() 
	return false
end

function modifier_sai_rat_reconnaissance_debuff:IsPurgable()
	return false
end

function modifier_sai_rat_reconnaissance_debuff:OnCreated( kv )
	self.ms_slow_percentage= self:GetAbility():GetSpecialValueFor("ms_slow_percentage") --initialize 
end
function modifier_sai_rat_reconnaissance_debuff:OnRefresh( kv )
end

function modifier_sai_rat_reconnaissance_debuff:OnRemoved()
end

function modifier_sai_rat_reconnaissance_debuff:OnDestroy()
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sai_rat_reconnaissance_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function modifier_sai_rat_reconnaissance_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow_percentage *-1
end

function modifier_sai_rat_reconnaissance_debuff:GetModifierProvidesFOWVision()
	return 1
end

--------------------------------------------------------------------------------
-- Effects
function sai_rat_reconnaissance:PlayEffects1( target )
	local particle_cast = "particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf"
	local sound_cast = "Hero_Tinker.Heat-Seeking_Missile.Impact"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, target )
end

function sai_rat_reconnaissance:PlayEffects2()
	local particle_cast = "particles/units/heroes/hero_tinker/tinker_missile_dud.vpcf"
	local sound_cast = "Hero_Tinker.Heat-Seeking_Missile_Dud"

	local attach = "attach_attack1"
	if self:GetCaster():ScriptLookupAttachment( "attach_attack3" )~=0 then attach = "attach_attack3" end
	local point = self:GetCaster():GetAttachmentOrigin( self:GetCaster():ScriptLookupAttachment( attach ) )

	-- play particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControlForward( effect_cast, 0, self:GetCaster():GetForwardVector() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, self:GetCaster() )
end