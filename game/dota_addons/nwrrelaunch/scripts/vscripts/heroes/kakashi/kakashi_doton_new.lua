kakashi_doton_new_lua = kakashi_doton_new_lua or class({})

function kakashi_doton_new_lua:GetAbilityTextureName()
	return "kakashi_doton"
end

function kakashi_doton_new_lua:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function kakashi_doton_new_lua:GetCastRange(location, target)
	local castrangebonus = 0
	local talentToCastRange = self:GetCaster():FindAbilityByName("special_bonus_kakashi_2"):GetLevel()
	if  talentToCastRange > 0 then
		castrangebonus = talentToCastRange:GetSpecialValueFor("value")
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function kakashi_doton_new_lua:OnSpellStart()
    local caster = self:GetCaster()
    self.target = self:GetCursorTarget()
	local target = self.target --for global variables and don't change all "target" to "self.target"
    self.ability = self
    self.target:EmitSound("kakashi_dog_cast")
	local damage = self.ability:GetSpecialValueFor("damage")
	local rootDuration = self.ability:GetSpecialValueFor("root_duration")
	
	local forward = caster:GetForwardVector()

	caster:Stop()
	target:Stop()
	target:SetForwardVector(-forward)
	
	target:AddNewModifier(caster, ability, "modifier_rooted", {duration = rootDuration})

	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	local dummy2 = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	local dummy3 = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:AddAbility("custom_point_dummy") --dummy_passive_vulnerable
	dummy2:AddAbility("custom_point_dummy")
	dummy3:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	local abl2 = dummy2:FindAbilityByName("custom_point_dummy")
	local abl3 = dummy3:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	if abl2 ~= nil then abl2:SetLevel(1) end
	if abl3 ~= nil then abl3:SetLevel(1) end
	
	local diff = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	local distance = forward * (diff - 100)
	local distanceForSides = forward * diff
	dummy:SetAbsOrigin(Vector(dummy:GetAbsOrigin().x + distance.x, dummy:GetAbsOrigin().y + distance.y, dummy:GetAbsOrigin().z - 100))
	dummy2:SetAbsOrigin(Vector(dummy2:GetAbsOrigin().x + distanceForSides.x, dummy2:GetAbsOrigin().y + distanceForSides.y, dummy2:GetAbsOrigin().z - 100))
	dummy3:SetAbsOrigin(Vector(dummy3:GetAbsOrigin().x + distanceForSides.x, dummy3:GetAbsOrigin().y + distanceForSides.y, dummy3:GetAbsOrigin().z - 100))
	local pakkunSpawn_particle = ParticleManager:CreateParticle("particles/units/heroes/kakashi/doton_dog_summon.vpcf", PATTACH_ABSORIGIN, dummy)
	ParticleManager:SetParticleControl(pakkunSpawn_particle, 0, dummy:GetAbsOrigin())
	dummy:SetOriginalModel("models/couriers/pakkun/pakkun.vmdl")
	dummy2:SetOriginalModel("models/uhei/dog_uhei.vmdl")
	dummy3:SetOriginalModel("models/guruko/dog_guruko.vmdl")
	dummy:SetModel("models/couriers/pakkun/pakkun.vmdl")
	dummy2:SetModel("models/uhei/dog_uhei.vmdl")
	dummy3:SetModel("models/guruko/dog_guruko.vmdl")
	dummy:SetModelScale(0.6)
	dummy2:SetModelScale(1.7)
	dummy3:SetModelScale(1.8)
	dummy:SetForwardVector(target:GetForwardVector())
	dummy2:SetForwardVector(target:GetForwardVector())
	dummy3:SetForwardVector(target:GetForwardVector())
	dummy:SetAngles(dummy:GetAnglesAsVector().x - 50, dummy:GetAnglesAsVector().y + 180, dummy:GetAnglesAsVector().z)
	dummy2:SetAngles(dummy2:GetAnglesAsVector().x - 90, dummy2:GetAnglesAsVector().y - 90, dummy2:GetAnglesAsVector().z)
	dummy3:SetAngles(dummy3:GetAnglesAsVector().x - 75, dummy3:GetAnglesAsVector().y + 90, dummy3:GetAnglesAsVector().z)
	
	--[[--this is create particles for dogs on the sides, but it doesn't work properly--
	local dogSides1_particle = ParticleManager:CreateParticle("particles/units/heroes/kakashi/doton_dog_summon.vpcf", PATTACH_ABSORIGIN, dummy2)
	local dogSides2_particle = ParticleManager:CreateParticle("particles/units/heroes/kakashi/doton_dog_summon.vpcf", PATTACH_ABSORIGIN, dummy3)
	ParticleManager:SetParticleControl(dogSides1_particle, 1, dummy2:GetAbsOrigin())
	ParticleManager:SetParticleControl(dogSides2_particle, 2, dummy3:GetAbsOrigin()) --проверить
	ParticleManager:SetParticleControlOrientation(dogSides1_particle, 1, dummy2:GetForwardVector(), dummy2:GetRightVector(), dummy2:GetUpVector()) --проверить
	ParticleManager:SetParticleControlOrientation(dogSides2_particle, 2, dummy3:GetForwardVector(), dummy3:GetRightVector(), dummy3:GetUpVector()) --проверить
	
	local pDummy1 = CreateUnitByName("npc_dummy_unit", dummy2:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	local pDummy2 = CreateUnitByName("npc_dummy_unit", dummy3:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	pDummy1:AddAbility("custom_point_dummy")
	pDummy2:AddAbility("custom_point_dummy")
	local pabl1 = dummy3:FindAbilityByName("custom_point_dummy")
	local pabl2 = dummy3:FindAbilityByName("custom_point_dummy")
	if pabl1 ~= nil then abl3:SetLevel(1) end
	if pabl2 ~= nil then abl3:SetLevel(1) end
	ParticleManager:CreateParticle("particles/units/heroes/kakashi/doton_dog_summon.vpcf", PATTACH_ABSORIGIN, pDummy1)
	ParticleManager:CreateParticle("particles/units/heroes/kakashi/doton_dog_summon.vpcf", PATTACH_ABSORIGIN, pDummy2)
	--need to find a solution how to make CreateParticle take into the angle of rotation of the dogs--]]
	
    dummy:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 0.5)
	dummy2:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 0.5)
	dummy3:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 0.5)
	
	--pDummy1:RemoveSelf()
	--pDummy2:RemoveSelf()
	
	local tick = 0
	Timers:CreateTimer(0.0, function ()
		if tick < 30 then
			tick = tick + 5
			dummy:SetAbsOrigin(Vector(dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z) + dummy:GetForwardVector() * 23)
			dummy2:SetAbsOrigin(Vector(dummy2:GetAbsOrigin().x, dummy2:GetAbsOrigin().y, dummy2:GetAbsOrigin().z) + dummy2:GetForwardVector() * 20)
			dummy3:SetAbsOrigin(Vector(dummy3:GetAbsOrigin().x, dummy3:GetAbsOrigin().y, dummy3:GetAbsOrigin().z) + dummy3:GetForwardVector() * 20)
			return 0.05
		else
			return nil
		end
	end)

	Timers:CreateTimer(0.5, function ()
	    ParticleManager:DestroyParticle(pakkunSpawn_particle, true)
	    --ParticleManager:DestroyParticle(dogSides1_particle, true)
	    --ParticleManager:DestroyParticle(dogSides2_particle, true)
	    ParticleManager:ReleaseParticleIndex(pakkunSpawn_particle)
	    --ParticleManager:ReleaseParticleIndex(dogSides1_particle)
	    --ParticleManager:ReleaseParticleIndex(dogSides2_particle)
		local blood_particle = ParticleManager:CreateParticle("particles/bloody_particle.vpcf", PATTACH_POINT, target)
		ParticleManager:SetParticleControl(blood_particle, 4, target:GetAbsOrigin())
		target:EmitSound("Hero_LifeStealer.consume")
		
		Timers:CreateTimer(0.5, function ()
		    dummy:RemoveSelf()
		    dummy2:RemoveSelf()
		    dummy3:RemoveSelf()

            local backstubDistance = forward * (diff + 100)
            local backstub = Vector(caster:GetAbsOrigin().x + backstubDistance.x, caster:GetAbsOrigin().y + backstubDistance.y, target:GetAbsOrigin().z)
		    ProjectileManager:ProjectileDodge(caster)
		    FindClearSpaceForUnit(caster, backstub, true)
			caster:EmitSound("Hero_PhantomLancer.SpiritLance.Impact")
			caster:MoveToTargetToAttack(target)
	        caster:StartGesture(ACT_DOTA_ATTACK2)
		end)
		
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
		
		Timers:CreateTimer(1.0, function ()
		    local range = self:GetSpecialValueFor("range")
	        local length = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	        length = range - range * (length / range)
			
			ParticleManager:DestroyParticle(blood_particle, true)
	        ParticleManager:ReleaseParticleIndex(blood_particle)
	        
	        local knockbackModifierTable =
	        {
	        	should_stun = 1,
	        	knockback_duration = 0.75,
	        	duration = 0.75,
	        	knockback_distance = length,
	        	knockback_height = 0,
	        	center_x = caster:GetAbsOrigin().x,
	        	center_y = caster:GetAbsOrigin().y,
	        	center_z = caster:GetAbsOrigin().z
	        }
	        target:AddNewModifier(caster, ability, "modifier_knockback", knockbackModifierTable)
		end)
	end)
end
