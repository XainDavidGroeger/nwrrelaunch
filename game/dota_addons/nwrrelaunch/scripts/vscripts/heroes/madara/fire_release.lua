madara_fire_release = class({})

function madara_fire_release:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("madara_katon")

	return true
end

function madara_fire_release:OnSpellStart()
	local caster = self:GetCaster()
	self.range = self:GetSpecialValueFor("fire_range")
	local wave_radius_start = self:GetSpecialValueFor("wave_radius_start")
	local wave_radius_end = self:GetSpecialValueFor("wave_radius_start")
	local wave_speed = self:GetSpecialValueFor("wave_speed")

	self.caster_origin = caster:GetAbsOrigin()
	self.caster_forward_vector = caster:GetForwardVector()

	EmitSoundOn("madara_fire_cast", caster)

	local projectile_table = {
		Ability = self,
		EffectName = "particles/econ/items/jakiro/jakiro_ti8_immortal_head/jakiro_ti8_dual_breath_fire.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = self.range,
		fStartRadius = wave_radius_start,
		fEndRadius = wave_radius_end,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * wave_speed,
		bProvidesVision = false
	}

	local proj = ProjectileManager:CreateLinearProjectile(projectile_table)
end

function madara_fire_release:OnProjectileHit(target, location)
	if not IsServer() then return end
	--Projectile reached destination
	if target == nil then
		local explosion_radius = self:GetSpecialValueFor("explosion_radius")
		local explosion_damage_table = {
			attacker = self:GetCaster(),
			damage = self:GetSpecialValueFor("explosion_damage"),
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}

		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			explosion_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			-- apply damage
			if enemy then
				explosion_damage_table.victim = enemy
				ApplyDamage( explosion_damage_table )
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("explosion_stun_duration")})
			end
			-- play effects
			-- self:PlayEffects( enemy )
		end

		EmitSoundOnLocationWithCaster(location, "madara_fire_explosion", self:GetCaster())

		local wood_release_ability =  self:GetCaster():FindAbilityByName("madara_wood_release")
		if wood_release_ability:IsTrained() then
	
			local trees = GridNav:GetAllTreesAroundPoint(location, explosion_radius, false) 
	
			for _,tree in pairs(trees) do
				if tree then
					wood_release_ability:BurnTree(tree)
				end
				-- play effects
				-- self:PlayEffects( enemy )
			end
		end

		local explosion_vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(explosion_vfx, 0, location)
		ParticleManager:SetParticleControl(explosion_vfx, 1, Vector(0,0,explosion_radius))
		ParticleManager:SetParticleControl(explosion_vfx, 2, Vector(0,0,explosion_radius))

		return
	end

	local new_origin = target:GetAbsOrigin() + Vector(-self.caster_forward_vector.x, -self.caster_forward_vector.y) * 10

	local final_distance = self.range - (target:GetAbsOrigin() - self.caster_origin):Length2D() -50
	local ditance_perc = final_distance/self.range 
	local max_duration = self:GetSpecialValueFor("knockback_duration")
	local final_duration = ditance_perc * max_duration

	local knockbackModifierTable =
	{
		should_stun = 0,
		knockback_duration = final_duration,
		duration = final_duration,
		knockback_distance = final_distance,
		knockback_height = 0,
		center_x = new_origin.x,
		center_y = new_origin.y,
		center_z = new_origin.z,
	}

	target:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackModifierTable )

	local damage_table = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("wave_damage"),
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}

	ApplyDamage(damage_table)

	return false
end

function madara_fire_release:OnProjectileThink(location)
	local wave_radius = self:GetSpecialValueFor("wave_radius_start")
	local wood_release_ability =  self:GetCaster():FindAbilityByName("madara_wood_release")
	if wood_release_ability:IsTrained() then

		local trees = GridNav:GetAllTreesAroundPoint(location, wave_radius, false) 

		for _,tree in pairs(trees) do
			if tree then
				wood_release_ability:BurnTree(tree)
			end
			-- play effects
			-- self:PlayEffects( enemy )
		end
	end
end