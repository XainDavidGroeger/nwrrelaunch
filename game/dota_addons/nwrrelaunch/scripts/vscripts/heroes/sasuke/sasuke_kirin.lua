sasuke_kirin = sasuke_kirin or class({})

function sasuke_kirin:GetAbilityTextureName()
	return "sasuke_kirin"
end

function sasuke_kirin:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_kirin:GetAOERadius()
	return 400
end


function sasuke_kirin:GetCastRange(location, target)
	return self:GetSpecialValueFor("cast_range")
end

function sasuke_kirin:GetCastPoint()
	local cast_point = self.BaseClass.GetCastPoint(self)
    
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_sasuke_4")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	cast_point = cast_point - 0.75
	    end
	end

	return cast_point
end

function sasuke_kirin:OnSpellStart()

	local targetpoint = self:GetCursorPosition()
	local caster = self:GetCaster()
	local ability = self

	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	self:GetCaster():EmitSound("Hero_Zuus.GodsWrath.Target")

	local particle = "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf"

	-- Lightning particle
	local pid = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(pid, 0, targetpoint)
    ParticleManager:SetParticleControl(pid, 1, targetpoint + Vector(0, 0, 1500))

	-- Teleport the caster to the target
	local caster_pos = caster:GetAbsOrigin()
	local blink_pos = targetpoint + ( caster_pos - targetpoint ):Normalized() * 100
	FindClearSpaceForUnit(caster, blink_pos, true)

	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		targetpoint, 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	for _, unit in pairs(targets) do

		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage( damageTable )
	end
end