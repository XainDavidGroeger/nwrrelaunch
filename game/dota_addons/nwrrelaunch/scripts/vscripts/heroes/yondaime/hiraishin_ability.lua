yondaime_hiraishin_jump = class({})
LinkLuaModifier("modifier_hiraishin_armor_debuff",
                "heroes/yondaime/modifiers/modifier_hiraishin_armor_debuff.lua", 
				LUA_MODIFIER_MOTION_NONE )

function yondaime_hiraishin_jump:GetClosestSeal(target_point)
	--Find the closest seal	
	local placed_seals = self:GetCaster().daggers

	local closest_seal = nil
	local min_dist = self:GetSpecialValueFor("radius") --Maximum allowed distance

	-- units_in_radius = FindUnitsInRadius(caster:GetTeamNumber(),
	-- 			      target_point,
	-- 				  nil, 
	-- 				  min_dist, 
	-- 				  DOTA_UNIT_TARGET_TEAM_BOTH, 
	-- 				  DOTA_UNIT_TARGET_ALL, 
	-- 				  0, 
	-- 				  FIND_CLOSEST, 
	-- 				  false)

	-- closest_kunai = Entities:FindByNameNearest("npc_marked_kunai", target_point, 0)
	-- print("kunai ------")
	-- print(closest_kunai)
	-- PrintTable(units_in_radius)

	-- DebugDrawCircle(target_point, Vector(255, 0, 0), 1, min_dist, false, 3)
	
	local dist = 0

	for k,v in pairs(placed_seals) do
		if not v:IsNull() then
			dist = target_point - v:GetAbsOrigin()
			if(	dist:Length2D() < self:GetSpecialValueFor("radius") )then
				
				if dist:Length2D() < min_dist then
					min_dist = dist:Length2D()
					closest_seal = v
				end
			
			end
		end
	end
	
	return closest_seal
end

function yondaime_hiraishin_jump:CastFilterResultLocation(target_point)

	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( vLoc )
		end
	end

	print("Trying to cast")
	local ability = self
	local caster = ability:GetCaster()
	local closest_seal = self:GetClosestSeal(target_point)
	local range = self:GetSpecialValueFor("radius")


	if closest_seal ~= nil then
		if (closest_seal:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < self:GetCastRange(target_point ,nil) then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	else
		return UF_FAIL_CUSTOM
	end
end


function yondaime_hiraishin_jump:OnSpellStart( keys )

	local ability = self
	local caster = ability:GetCaster()
	local target = ability:GetCursorPosition()
	caster.ulti = ability

	local closest_seal = self:GetClosestSeal(target)

	hiraishin_dash(caster, closest_seal, ability)

end


function yondaime_hiraishin_jump:CastFilterResultTarget( target )
	local ability = self
	local caster = ability:GetCaster()

	if target:GetUnitName() == "npc_marked_kunai" then 
		return UF_SUCCESS
	else
		return UF_FAIL_CUSTOM
	end
	return ""
end

function yondaime_hiraishin_jump:GetCustomCastError()

	return "NO KUNAI NEARBY"
end


function hiraishin_dash( caster, closest_seal, ability )

	local direction = (closest_seal:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

	
	local target_entities = FindUnitsInLine(caster:GetTeamNumber(),
										   caster:GetAbsOrigin() - direction*200,
										   closest_seal:GetAbsOrigin() + direction*200,
										   nil,
										   ability:GetSpecialValueFor("search_width"),
										   DOTA_UNIT_TARGET_TEAM_ENEMY,
										   DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
										   DOTA_UNIT_TARGET_FLAG_NONE)

	
	local timer_tbl =
	{
		callback = hiraishin_dash_timer,
		caster = caster,
		closest_seal = closest_seal,
		target_entities = target_entities,
		ability = ability
	}
	
	-- --Movement
	Timers:CreateTimer(timer_tbl)

	hiraishin_dash_timer(caster, ability, closest_seal, target_entities)
end

function hiraishin_dash_timer(game_entity, keys)

	local target_entities = keys.target_entities
	local caster=keys.caster
	local ability = keys.ability
	local closest_seal = keys.closest_seal

	local particle_slash_name = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf"
	local particle_trail_name = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf"
	local slash_sound = "Hero_Juggernaut.OmniSlash.Damage"

	if target_entities == nil then
		return nil
	end

	
	for k,target in pairs(target_entities) do
	
		local trail_effect_index = ParticleManager:CreateParticle( particle_trail_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( trail_effect_index, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( trail_effect_index, 1, caster:GetAbsOrigin() )
		
		Timers:CreateTimer( 0.1, function()
				ParticleManager:DestroyParticle( trail_effect_index, false )
				ParticleManager:ReleaseParticleIndex( trail_effect_index )
				return nil
			end
		)


		target:AddNewModifier(caster, caster.ulti, "modifier_hiraishin_armor_debuff", {duration = caster.ulti:GetSpecialValueFor( "armor_duration")})
		
		
		local damage = caster:GetAverageTrueAttackDamage(caster)
		local extra_damage = caster.ulti:GetSpecialValueFor( "damage")
		local damage = damage / 100 * extra_damage


		ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})
		--caster:PerformAttack(target, true, false, true, false)
		
		-- Slash particles
		local slash_effect_index = ParticleManager:CreateParticle( particle_slash_name, PATTACH_ABSORIGIN_FOLLOW, target )
		StartSoundEvent( slash_sound , caster )

		Timers:CreateTimer( 0.1, function()
				ParticleManager:DestroyParticle( slash_effect_index, false )
				ParticleManager:ReleaseParticleIndex( slash_effect_index )
				StopSoundEvent( slash_sound, caster )
				return nil
			end
		)	
	
		FindClearSpaceForUnit(caster,target:GetAbsOrigin(),false)
		
		target_entities[ k ] = nil

		return 0.05
	end
	
	-- local closest_seal = closest_seal
	
	local trail_effect_index = ParticleManager:CreateParticle( particle_trail_name, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( trail_effect_index, 0, closest_seal:GetAbsOrigin() )
	ParticleManager:SetParticleControl( trail_effect_index, 1, caster:GetAbsOrigin() )

	FindClearSpaceForUnit(caster, closest_seal:GetAbsOrigin(), false)

	
	Timers:CreateTimer( 0.1, function()
			ParticleManager:DestroyParticle( trail_effect_index, false )
			ParticleManager:ReleaseParticleIndex( trail_effect_index )
			return nil
		end
	)
	
	return nil
end
