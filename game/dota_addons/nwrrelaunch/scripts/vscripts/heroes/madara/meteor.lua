madara_meteor = class({})

function madara_meteor:Precache( context )
    PrecacheResource( "soundfile", "soundevents/madara_meteor_cast.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/madara_meteor_impact.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/madara/madara_ulti_cast_talk.vsndevts", context )

    PrecacheResource( "particle", "particles/generic_gameplay/generic_silence.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/madara/shadow_2.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/madara/burning_tree.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/deidara/c4_explo_base.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf", context )
end

function madara_meteor:OnSpellStart()
	self.target_point = self:GetCursorPosition()
	self:CastMeteorShadow(self.target_point)
end

function madara_meteor:OnChannelFinish(interrupted)
	if not IsServer() then return end
	if not interrupted then
		local caster = self:GetCaster()
		self:LaunchMeteor(self.target_point)
		--Second talent meteor
		if caster:FindAbilityByName("special_bonus_madara_second_meteor"):IsTrained() then
			Timers:CreateTimer({
				endTime = 2,
				callback = function()
					self:CastMeteorShadow(self.target_point)
				end
			})
			Timers:CreateTimer({
				endTime = 4,
				callback = function()
					self:LaunchMeteor(self.target_point)
				end
			})
		end
	end
end

function madara_meteor:CastMeteorShadow(target_point)
	local caster = self:GetCaster()
	local caster_origin = caster:GetAbsOrigin()
	local land_time = self:GetSpecialValueFor("land_time")
	local travel_speed = self:GetSpecialValueFor("travel_speed")
	local vision_distance = self:GetSpecialValueFor("vision_distance")
	local end_vision_duration = self:GetSpecialValueFor("end_vision_duration")

	local point_difference_normalized = (target_point - caster_origin):Normalized()
	local velocity_per_second = target_point:Normalized() * travel_speed
	--Create a particle effect consisting of the meteor falling from the sky and landing at the target point.
	local meteor_fly_original_point = target_point + Vector (-900, 0, 2000)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
	local meteor_fly_original_point_2 = target_point + Vector (-900, 0, 2000)
	local meteor_fly_original_point_3 = (target_point - (velocity_per_second * land_time)) + Vector (0, 0, 100)
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly_shadow.vpcf", PATTACH_ABSORIGIN, caster)
	 	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
		ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, meteor_fly_original_point_2)
		ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(3.8 , 0, 0))
	 self.meteor_fly_vfx = chaos_meteor_fly_particle_effect

	caster:EmitSound("madara_ulti_cast_talk")
	caster:EmitSound("madara_meteor_cast")
end

function madara_meteor:LaunchMeteor(target_point)
	local caster = self:GetCaster()
	local caster_origin = caster:GetAbsOrigin()
	local land_time = self:GetSpecialValueFor("land_time")
	local travel_speed = self:GetSpecialValueFor("travel_speed")
	local vision_distance = self:GetSpecialValueFor("vision_distance")
	local end_vision_duration = self:GetSpecialValueFor("end_vision_duration")

	local point_difference_normalized = (target_point - caster_origin):Normalized()
	local velocity_per_second = target_point:Normalized() * travel_speed
	
	caster:EmitSound("Hero_Invoker.ChaosMeteor.Cast")

	--Create a particle effect consisting of the meteor falling from the sky and landing at the target point.
	local meteor_fly_original_point = (target_point - (velocity_per_second * land_time)) + Vector (0, 0, 1000)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, target_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(1.3, 0, 0))

	Timers:CreateTimer({
		endTime = self:GetSpecialValueFor("delay_to_dmg"),
		callback = function()
			local explosion_radius = self:GetSpecialValueFor("radius")
			local explosion_damage_table = {
				attacker = self:GetCaster(),
				damage = self:GetSpecialValueFor("damage"),
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			}
	
			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(),	-- int, your team number
				target_point,	-- point, center point
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
					enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
				end
				-- play effects
				-- self:PlayEffects( enemy )
			end

			local wood_release_ability =  self:GetCaster():FindAbilityByName("madara_wood_release")
			if wood_release_ability:IsTrained() then
		
				local trees = GridNav:GetAllTreesAroundPoint(target_point, explosion_radius, false) 
		
				for _,tree in pairs(trees) do
					if tree then
						wood_release_ability:BurnTree(tree)
					end
					-- play effects
					-- self:PlayEffects( enemy )
				end
			end

			local explosion_vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(explosion_vfx, 0, target_point)
			ParticleManager:SetParticleControl(explosion_vfx, 1, Vector(explosion_radius,0,0))

			caster:EmitSound("Hero_Warlock.RainOfChaos.Cast")

		end
	})
end