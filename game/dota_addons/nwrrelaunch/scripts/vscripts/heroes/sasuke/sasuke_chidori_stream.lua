sasuke_chidori_stream = sasuke_chidori_stream or class({})

function sasuke_chidori_stream:GetAbilityTextureName()
	return "sasuke_chidori_stream"
end

function sasuke_chidori_stream:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_chidori_stream:GetCastRange(location, target)
	return self:GetSpecialValueFor("radius")
end


function sasuke_chidori_stream:OnSpellStart()

	self.stream = ParticleManager:CreateParticle("particles/units/heroes/sasuke/stream/stream.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( self.stream, 0, self:GetCaster():GetAbsOrigin() )

	self:GetCaster():EmitSound("Hero_StormSpirit.Orchid_BallLightning")

	local targets = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

	for _, unit in pairs(targets) do


		unit:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})


		local damageTable = {
			victim = unit,
			attacker = self:GetCaster(), 
			damage = self:GetSpecialValueFor("aoe_damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage(damageTable)  

	end

end

