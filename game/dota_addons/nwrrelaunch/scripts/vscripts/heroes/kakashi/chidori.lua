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
	local sound_impact = keys.sound_impact
	local particle_impact = keys.particle_impact


	caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_4, 1)

	caster:EmitSound(keys.sound_cast)
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
			if ability4:IsTrained() then
				damage = damage + 420
			end

			local damageTable = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = keys.ability:GetAbilityDamageType()
			}
			ApplyDamage( damageTable )

			target:EmitSound(sound_impact)



			FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), false )
			return nil
		end
		return 0.03
	end)
end

function ChannelChidori( keys )
	keys.caster:EmitSound(keys.sound_cast)
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, keys.modifier_caster, {})
	keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 0.3)
end

function RemoveChannelChidori(keys)
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
	keys.caster:RemoveModifierByName(keys.modifier_caster)
end

function applyThunderEffect (keys)





end
