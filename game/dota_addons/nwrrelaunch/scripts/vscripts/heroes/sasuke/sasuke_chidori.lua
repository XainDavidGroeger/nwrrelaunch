sasuke_chidori = sasuke_chidori or class({})


function sasuke_chidori:Precache( context )
    PrecacheResource( "soundfile",   "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_chidori_cast.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_chidori_cast_talking.vsndevts", context )

    PrecacheResource( "particle",  "particles/units/heroes/sasuke/chidori/step.vpcf", context )
    PrecacheResource( "particle",  "particles/units/heroes/sasuke/chidori/impact.vpcf", context )
end

function sasuke_chidori:GetAbilityTextureName()
	return "sasuke_chidori"
end

function sasuke_chidori:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_chidori:GetCastRange(location, target)
	local ability3 = self:GetCaster():FindAbilityByName("special_bonus_sasuke_3")
	if ability3 ~= nil then
	    if ability3:GetLevel() > 0 then
	    	return self:GetSpecialValueFor("range") + 275
	    else
	    	return self:GetSpecialValueFor("range")
	    end
	end
end

function sasuke_chidori:ProcsMagicStick()
    return true
end

function sasuke_chidori:OnSpellStart(recastVector, warpVector, bInterrupted)

	-- Preventing projectiles getting stuck in one spot due to potential 0 length vector
	if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end

	local target = self:GetCursorPosition()
	local caster = self:GetCaster()
	local ability = self
	local root_duration = ability:GetSpecialValueFor("root_duration")
	local crit_damage = ability:GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_sasuke_4")
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local bonus_damage = caster:GetAverageTrueAttackDamage(nil) * (crit_damage / 100)
	print(bonus_damage)
	local damage = bonus_damage + base_damage

	local max_distance = self:GetSpecialValueFor("max_distance") + self:GetCaster():FindTalentValue("special_bonus_sasuke_3")

	caster:EmitSound("sasuke_chidori_cast")
	caster:EmitSound("sasuke_chidori_cast_talking")

	local original_position	= self:GetCaster():GetAbsOrigin()
	
	local final_position = self:GetCaster():GetAbsOrigin() + ((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() 
	* math.max(math.min(((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()) 
	* Vector(1, 1, 0)):Length2D(), max_distance + self:GetCaster():GetCastRangeBonus()), self:GetSpecialValueFor("min_distance")))
	
	if recastVector then
		final_position	= self:GetCaster():GetAbsOrigin() + recastVector
	end
	
	if warpVector then
		final_position	= GetGroundPosition(self:GetCaster():GetAbsOrigin() + warpVector, nil)
	end

	self.original_vector	= (final_position - self:GetCaster():GetAbsOrigin()):Normalized() * (max_distance + self:GetCaster():GetCastRangeBonus())

	self:GetCaster():SetForwardVector(self.original_vector:Normalized())
	
	local step_particle = ParticleManager:CreateParticle("particles/units/heroes/sasuke/chidori/step.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(step_particle, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(step_particle, 1, final_position)
	ParticleManager:ReleaseParticleIndex(step_particle)

	local bHeroHit	= false

	for _, enemy in pairs(FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), final_position, nil, self:GetSpecialValueFor("path_width"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
		
		self.impact_particle = ParticleManager:CreateParticle("particles/units/heroes/sasuke/chidori/impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:SetParticleControlEnt(self.impact_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(self.impact_particle)
		
		self:GetCaster():SetAbsOrigin(enemy:GetAbsOrigin() - self:GetCaster():GetForwardVector())
		
		if enemy:IsMagicImmune() == false then
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_rooted", {duration = root_duration })
			ApplyDamage({ victim =enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
		end
		
		if enemy:IsHero() and not bHeroHit then
			bHeroHit = true
		end
	end

	self.impact_particle = nil
	
	if not warpVector then
		FindClearSpaceForUnit(self:GetCaster(), final_position, false)
	else
		FindClearSpaceForUnit(self:GetCaster(), original_position, false)
	end

	self:GetCaster():EmitSound("Hero_VoidSpirit.AstralStep.End")

end