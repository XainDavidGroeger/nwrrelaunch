-- function resetCooldown( keys )
-- 	local ability3 = keys.caster:FindAbilityByName("special_bonus_sakura_2")
-- 	if ability3 ~= nil then
-- 	    if ability3:IsTrained() then
-- 	    	keys.ability:EndCooldown()
-- 	    	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 3)
-- 	    end
-- 	end

-- 	local stun_duration_talent = keys.caster:FindAbilityByName("special_bonus_sakura_5")
-- 	if ability3 ~= nil then
-- 	    if ability3:IsTrained() then
-- 	    	keys.ability:EndCooldown()
-- 	    	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 3)
-- 	    end
-- 	end
-- end

sakura_earth_slam = class({})

function sakura_earth_slam:ProcsMagicStick()
	return true
end

function sakura_earth_slam:OnAbilityPhaseStart()
	EmitSoundOn("sakura_slam", self:GetCaster())
	EmitSoundOn("sakura_slam_cast", self:GetCaster())
	return true
end

function sakura_earth_slam:GetCooldown(level)
	local caster = self:GetCaster()
	if self:GetCaster():HasTalent("special_bonus_sakura_2") then
		return self.BaseClass.GetCooldown( self, level ) + caster:FindAbilityByName("special_bonus_sakura_2"):GetSpecialValueFor("value")
	else
		return self.BaseClass.GetCooldown( self, level )
	end
end

function sakura_earth_slam:OnSpellStart()
	print("spellstart")
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("stomp_damage")
	
	local stun_duration
	if caster:HasTalent("special_bonus_sakura_5") then
		stun_duration = self:GetSpecialValueFor("stun_duration") + caster:FindTalentValue("special_bonus_sakura_5")
	else
		stun_duration = self:GetSpecialValueFor("stun_duration")
	end
	print(stun_duration)

	local units = FindUnitsInRadius(
					caster:GetTeamNumber(), 
					origin, 
					nil, 
					radius, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
					DOTA_UNIT_TARGET_FLAG_NONE, 
					FIND_ANY_ORDER, 
					false)
					
	local damage_table = {
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = self
	}

	for i=1,#units do
		units[i]:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration})
		damage_table.victim = units[i]
		ApplyDamage(damage_table)
	end

	local vfx = ParticleManager:CreateParticle("particles/units/heroes/sakura/sakura_earth_slam.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(vfx, 0, origin)
	ParticleManager:SetParticleControl(vfx, 1, Vector(radius, 0, radius))

	caster:EmitSound("sakura_slam_impact")
end