sasuke_chidori_stream = sasuke_chidori_stream or class({})

function sasuke_chidori_stream:GetAbilityTextureName()
	return "sasuke_chidori_stream"
end

function sasuke_chidori_stream:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_chidori_stream:GetCastRange(location, target)
	local ability5 = self:GetCaster():FindAbilityByName("special_bonus_sasuke_5")
	if ability5 ~= nil then
	    if ability5:GetLevel() > 0 then
	    	return self:GetSpecialValueFor("radius") + 225
	    else
	    	return self:GetSpecialValueFor("radius")
	    end
	end
end

function sasuke_chidori_stream:OnSpellStart()

	self.stream = ParticleManager:CreateParticle("particles/units/heroes/sasuke/stream/stream.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( self.stream, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.stream, 3, Vector(self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_sasuke_5")  ,0,0) )

	self:GetCaster():EmitSound("sasuke_stream_cast")

	local targets = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, 
		self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_sasuke_5"), DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

	for _, unit in pairs(targets) do


		unit:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
		local damage = self:GetSpecialValueFor("aoe_damage") + self:GetCaster():FindTalentValue("special_bonus_sasuke_2")

		local damageTable = {
			victim = unit,
			attacker = self:GetCaster(), 
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage(damageTable)  

	end

end

