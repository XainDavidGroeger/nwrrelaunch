--[[
	Author: LearningDave
	Date: 25.10.2015.
	Initialize the data we require for the ability
]]
function fire_release_initialize( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability	
	local ability_level = ability:GetLevel() - 1
	local point = keys.target_points[1]

	-- Ability variables
	ability.traveled = 0
	ability.direction = (point - caster_location):Normalized()
	ability.currentPos = caster_location
	ability.percent_movespeed = 100

	ability.max_range = ability:GetLevelSpecialValueFor( "fire_range", ability_level )
	ability.max_movespeed = ability:GetLevelSpecialValueFor( "wave_speed", ability_level )
	ability.radius = ability:GetLevelSpecialValueFor( "wave_radius_start", ability_level )
	ability.vision_radius = ability:GetLevelSpecialValueFor( "wave_radius_start", ability_level )	
	ability.tree_width = ability:GetLevelSpecialValueFor( "fire_range", ability_level ) -- Double the radius because the original feels too small
end
--[[
	Author: LearningDave
	Date: 25.10.2015.
	Releases a Fire(linear Projectile) which burn trees if 'wood_release' is skilled.
]]
function ReleaseFire( keys )
	local target_point = keys.target_points[1]
	local ability_index = keys.caster:FindAbilityByName("madara_wood_release"):GetAbilityIndex()
    local wood_ability = keys.caster:GetAbilityByIndex(ability_index)
    local wood_ability_level = keys.caster:GetAbilityByIndex(ability_index):GetLevel()
    local tree_burn_aoe = wood_ability:GetLevelSpecialValueFor("tree_vision", wood_ability_level)
    local tree_burn_duration = wood_ability:GetLevelSpecialValueFor("tree_burn_duration", wood_ability_level)
    local burn_damage = wood_ability:GetLevelSpecialValueFor("burn_damage", wood_ability_level)
    local burn_ms_slow_percentage = wood_ability:GetLevelSpecialValueFor("burn_ms_slow_percentage", wood_ability_level)
    local burn_buff_duration = wood_ability:GetLevelSpecialValueFor("burn_buff_duration", wood_ability_level)
	local caster_location = keys.caster:GetAbsOrigin()
	local range = keys.ability:GetLevelSpecialValueFor("fire_range", keys.ability:GetLevel() - 1)
	local wave_radius_start = keys.ability:GetLevelSpecialValueFor("wave_radius_start", keys.ability:GetLevel() - 1)
	local wave_radius_end = keys.ability:GetLevelSpecialValueFor("wave_radius_end", keys.ability:GetLevel() - 1)
	local wave_speed = keys.ability:GetLevelSpecialValueFor("wave_speed", keys.ability:GetLevel() - 1)
	local ability = keys.ability
	local point_difference_normalized = (target_point - caster_location):Normalized()
	local velocity = point_difference_normalized * wave_speed
	local stopCheck = true
	local info = 
	{
			Ability = keys.ability,
        	EffectName = keys.fire_particle,
        	vSpawnOrigin = keys.caster:GetAbsOrigin(),
        	fDistance = range,
        	fStartRadius = wave_radius_start,
        	fEndRadius = wave_radius_end,
        	Source = keys.caster,
        	bHasFrontalCone = false,
        	bReplaceExisting = false,
        	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = velocity,
			bProvidesVision = false
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)

	-- If the ability 'madara_wood_release' is skilled, the projectile checks if it hits trees. If so the trees get burned and will be replaced by burning trees
	if wood_ability_level > 0 then
		-- Traverse
		Timers:CreateTimer( function()
				-- Traverse the point
				ability.currentPos = ability.currentPos + ( ability.direction * ability.percent_movespeed/100 * ability.max_movespeed * 1/30 )
				ability.traveled = ability.traveled + ability.max_movespeed * 1/30
				-- Check for nearby trees, destroy them if they exist
				if GridNav:IsNearbyTree( ability.currentPos, ability.radius, true ) then

				local trees = GridNav:GetAllTreesAroundPoint(ability.currentPos, ability.tree_width, false) 
				if trees then
					for _,tree in pairs(trees) do
						local origin = tree:GetAbsOrigin()
						xcoord = origin.x
						ycoord = origin.y
						--local dummy = CreateUnitByName( "npc_burning_tree", Vector(xcoord, ycoord, 0.0), false, keys.caster, nil, keys.caster:GetTeamNumber() )
						--dummy:GetAbilityByIndex(0):SetLevel(wood_ability_level)
						GridNav:DestroyTreesAroundPoint(origin, 40, true)
						local treesSecond = GridNav:GetAllTreesAroundPoint(origin, 50, false) 
						
						local particle = ParticleManager:CreateParticle("particles/units/heroes/madara/burning_tree.vpcf", PATTACH_CUSTOMORIGIN, nil) 
          				ParticleManager:SetParticleControl(particle , 0, origin)
          				print(tree_burn_aoe)
          				Timers:CreateTimer( function()
          						local targetEntities = FindUnitsInRadius(keys.caster:GetTeamNumber(), origin, nil, tree_burn_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
							    if targetEntities then
							      for _,oneTarget in pairs(targetEntities) do
							        local modfifier = oneTarget:FindModifierByName("burning_tree_dot")
							        if modifier == nil then
							          wood_ability:ApplyDataDrivenModifier(keys.caster, oneTarget, "burning_tree_dot", {Duration = tree_burn_duration})
							          local particle = ParticleManager:CreateParticle("particles/dire_fx/fire_barracks_glow_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, nil) 
							          ParticleManager:SetParticleControl(particle , 0, oneTarget:GetAbsOrigin())
							        end
							      end
							    end

          						if stopCheck then
          							return 0.3
          						else
          							return nil
          						end
							  
						end
					  	)

          				Timers:CreateTimer( tree_burn_duration, function()
          						stopCheck = false
						   		ParticleManager:DestroyParticle(particle, true)
							  return nil
						end
					  	)
					end
				end

				end
				
				-- Check if damage point reach the maximum range, if so, delete the timer
				if ability.traveled < ability.max_range then
					return 1/30
				else
					return nil
				end
			end
		)
	end

end		
--[[
	Author: LearningDave
	Date: 25.10.2015.
	Pushes targets which were hit by the fire projectile.
]]
function fireKnockback(keys)
	local fire_range = keys.ability:GetLevelSpecialValueFor("fire_range", keys.ability:GetLevel() - 1)
	local vCaster = keys.caster:GetAbsOrigin()
	local vTarget = keys.target:GetAbsOrigin()
	local len = ( vTarget - vCaster ):Length2D()
	local dis = fire_range - len
	print(dis)
	if dis < 0 then
		dis = dis * -1
	end
	len = keys.distance - keys.distance * ( len / keys.range )
	local knockbackModifierTable =
	{
		should_stun = 0,
		knockback_duration = 0.6,
		duration = 0.6,
		knockback_distance = dis,
		knockback_height = 0,
		center_x = keys.caster:GetAbsOrigin().x,
		center_y = keys.caster:GetAbsOrigin().y,
		center_z = keys.caster:GetAbsOrigin().z
	}
	keys.target:AddNewModifier( keys.caster, nil, "modifier_knockback", knockbackModifierTable )
end
--[[
	Author: LearningDave
	Date: 25.10.2015.
	Creates the particles for the explosion effects at the end of the skill
]]
function fireExplosion(keys)
	local target_point = keys.target_points[1]

	-- todo
	
end


function applyDamageAndStun( keys )

	local target_point = keys.target_points[1]
	local ability = keys.ability
	local caster = keys.caster

	local radius = ability:GetLevelSpecialValueFor("explosion_radius", ability:GetLevel() - 1)
	local damage = ability:GetLevelSpecialValueFor("explosion_damage",ability:GetLevel() - 1)
	local duration = ability:GetLevelSpecialValueFor("explosion_stun_duration",ability:GetLevel() - 1)

	

	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		target_point, 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local ability4 = caster:FindAbilityByName("special_bonus_madara_4")
	if ability4 ~= nil then
	    if ability4:IsTrained() then
	    	damage = damage + 160
	    end
	end

	local ability6 = caster:FindAbilityByName("special_bonus_madara_6")
	if ability6 ~= nil then
	    if ability6:IsTrained() then
	    	duration = duration + 1
	    end
	end

	for _, unit in pairs(targets) do

		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType()
		}
		ApplyDamage( damageTable )

		unit:AddNewModifier(unit, ability, "modifier_stunned", {duration = duration})

	end

end


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

	print(target)

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