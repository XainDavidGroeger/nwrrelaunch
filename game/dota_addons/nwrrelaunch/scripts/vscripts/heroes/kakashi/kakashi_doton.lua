kakashi_doton = kakashi_doton or class({})

function kakashi_doton:GetAbilityTextureName()
	return "kakashi_doton"
end

function kakashi_doton:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function kakashi_doton:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_kakashi_2") ~= nil then
		if self:GetCaster():FindAbilityByName("special_bonus_kakashi_2"):GetLevel() > 0 then
			castrangebonus = 325
		end
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function kakashi_doton:OnSpellStart()
    self.caster = self:GetCaster()
    local caster = self.caster
    self.target = self:GetCursorTarget()
	local target = self.target --for global variables and don't change all "target" to "self.target"
    self.ability = self
    self.target:EmitSound("kakashi_dog_cast")
	self.caster:EmitSound("kakashi_doton_cast_talking")
	local damage = self.ability:GetSpecialValueFor("damage")
	local rootDuration = self.ability:GetSpecialValueFor("stun_duration")
	
	local forward = caster:GetForwardVector()

	
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = rootDuration})

	local dummy2 = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	local dummy3 = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy2:AddAbility("custom_point_dummy")
	dummy3:AddAbility("custom_point_dummy")
	local abl2 = dummy2:FindAbilityByName("custom_point_dummy")
	local abl3 = dummy3:FindAbilityByName("custom_point_dummy")
	if abl2 ~= nil then abl2:SetLevel(1) end
	if abl3 ~= nil then abl3:SetLevel(1) end
	
	local diff = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	local distance = forward * (diff - 100)
	local distanceForSides = forward * diff
	dummy2:SetAbsOrigin(Vector(dummy2:GetAbsOrigin().x + distanceForSides.x, dummy2:GetAbsOrigin().y + distanceForSides.y, dummy2:GetAbsOrigin().z - 100))
	dummy3:SetAbsOrigin(Vector(dummy3:GetAbsOrigin().x + distanceForSides.x, dummy3:GetAbsOrigin().y + distanceForSides.y, dummy3:GetAbsOrigin().z - 100))
	local pakkunSpawn_particle = ParticleManager:CreateParticle("particles/units/heroes/kakashi/doton_dog_summon.vpcf", PATTACH_ABSORIGIN, dummy)
	ParticleManager:SetParticleControl(pakkunSpawn_particle, 0, dummy2:GetAbsOrigin())
	dummy2:SetOriginalModel("models/uhei/dog_uhei.vmdl")
	dummy3:SetOriginalModel("models/guruko/dog_guruko.vmdl")
	dummy2:SetModel("models/uhei/dog_uhei.vmdl")
	dummy3:SetModel("models/guruko/dog_guruko.vmdl")
	dummy2:SetModelScale(1.7)
	dummy3:SetModelScale(1.8)
	dummy2:SetForwardVector(target:GetForwardVector())
	dummy3:SetForwardVector(target:GetForwardVector())
	dummy2:SetAngles(dummy2:GetAnglesAsVector().x - 90, dummy2:GetAnglesAsVector().y - 90, dummy2:GetAnglesAsVector().z)
	dummy3:SetAngles(dummy3:GetAnglesAsVector().x - 75, dummy3:GetAnglesAsVector().y + 90, dummy3:GetAnglesAsVector().z)
	
	dummy2:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 0.5)
	dummy3:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 0.5)
	
	DebugPrint(damage)
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
	
	local tick = 0
	Timers:CreateTimer(0.0, function ()
		if tick < 30 then
			tick = tick + 5
			dummy2:SetAbsOrigin(Vector(dummy2:GetAbsOrigin().x, dummy2:GetAbsOrigin().y, dummy2:GetAbsOrigin().z) + dummy2:GetForwardVector() * 20)
			dummy3:SetAbsOrigin(Vector(dummy3:GetAbsOrigin().x, dummy3:GetAbsOrigin().y, dummy3:GetAbsOrigin().z) + dummy3:GetForwardVector() * 20)
			return 0.05
		else
			return nil
		end
	end)

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
		dummy2:RemoveSelf()
		dummy3:RemoveSelf()
	end)
	

	Timers:CreateTimer(1.0, function ()
	local range = self:GetSpecialValueFor("range")
		local length = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
		length = range - range * (length / range)
		
		ParticleManager:DestroyParticle(blood_particle, true)
		ParticleManager:ReleaseParticleIndex(blood_particle)
	 
	end)
end
