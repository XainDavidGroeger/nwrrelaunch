function AddPhysics(caster)
	Physics:Unit(caster)
	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)	
end

function RemovePhysics(caster)
	caster:SetPhysicsAcceleration(Vector(0,0,0))
	caster:SetPhysicsVelocity(Vector(0,0,0))
	caster:OnPhysicsFrame(nil)
	caster:PreventDI(false)
	caster:SetAutoUnstuck(true)
	caster:FollowNavMesh(true)
end

function FinishChidori(keys)
	RemovePhysics(keys.caster)
	keys.caster:RemoveModifierByName(keys.modifier_caster)
	keys.caster:RemoveModifierByName("modifier_raikiri_stunned")
	keys.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_5) --maybe it's not needed...
	keys.caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_4)
end

function Launch(keys)	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local velocity = ability:GetLevelSpecialValueFor("speed", ability_level)
	local particle_impact = keys.particle_impact

	caster:EmitSound("kakashi_raikiri_loop")

	caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_4, 1)

	AddPhysics(caster)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_raikiri_stunned", {})
	-- Movement
	Timers:CreateTimer(0, function()
		local vector = target:GetAbsOrigin() - caster:GetAbsOrigin()
		local direction = vector:Normalized()
		caster:SetPhysicsVelocity(direction * velocity)
		caster:SetForwardVector(direction)
		if not target:IsAlive() then
			FinishChidori(keys)
			return nil
		elseif vector:Length2D() <= 2 * target:GetPaddedCollisionRadius() then

			local enemy_loc = target:GetAbsOrigin()
			local impact_pfx = ParticleManager:CreateParticle(particle_impact, PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControl(impact_pfx, 0, enemy_loc)
			ParticleManager:SetParticleControlEnt(impact_pfx, 3, target, PATTACH_POINT_FOLLOW, "attach_origin", enemy_loc, true)
			FinishChidori(keys)

			local damage = keys.ability:GetSpecialValueFor("damage")

			local ability4 = caster:FindAbilityByName("special_bonus_kakashi_4")
			if ability4 ~= nil then
			    if ability4:IsTrained() then
			    	damage = damage + 420
			    end
			end

			local damageTable = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = keys.ability:GetAbilityDamageType()
			}
			ApplyDamage( damageTable )

			ability:ApplyDataDrivenModifier(caster, target, "modifier_raikiri_slow", {})

			FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), false )
			caster:StopSound("kakashi_raikiri_loop")
			target:EmitSound("kakashi_raikiri_impact")
			caster:EmitSound("kakashi_raikiri_impact_talking")
			return nil
		end
		return 0.03
	end)
end

function ChannelChidori( keys )
    --[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if keys.target:FindModifierByName("modifier_item_lotus_orb_active") then
        CanBeReflected(false, keys.target, ability)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
	if keys.target:HasItemInInventory("item_sphere") then
	    keys.ability:SetChanneling(false)
	    keys.ability:EndChannel(true)
        if keys.target:TriggerSpellAbsorb(keys.ability) then return end
		
		return
	end

	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, keys.modifier_caster, {})
	keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 0.3)
end

function RemoveChannelChidori(keys)
	keys.caster:StopSound("kakashi_raikiri_cast")
	keys.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
	keys.caster:RemoveModifierByName(keys.modifier_caster)
end

function applyThunderEffect (keys)





end
