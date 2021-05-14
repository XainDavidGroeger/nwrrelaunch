LinkLuaModifier("modifier_haku_needles_thinker", "heroes/haku/needles", LUA_MODIFIER_MOTION_NONE)

haku_needles = haku_needles or class({})

function haku_needles:OnAbilityPhaseStart()
	local sound_name = "haku_needles"
	local random = math.random(1, 2)

	if random == 2 then
		sound_name = "haku_needles_2"
	end

	self:GetCaster():EmitSound(sound_name)

	return true
end

function haku_needles:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function haku_needles:OnSpellStart()
	if not IsServer() then return end

	local target_point = self:GetCursorPosition()
	local duration = (self:GetSpecialValueFor("wave_interval") * self:GetSpecialValueFor("wave_count")) + self:GetSpecialValueFor("delay") + 0.1

	local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_haku_needles_thinker", {duration = duration}, target_point, self:GetCaster():GetTeamNumber(), false)

	-- Creates flying vision area
	self:CreateVisibilityNode(target_point, self:GetSpecialValueFor("radius"), duration)
end

modifier_haku_needles_thinker = modifier_haku_needles_thinker or class({})

function modifier_haku_needles_thinker:OnCreated()
	if not IsServer() then return end

	self.wave_count = self:GetAbility():GetSpecialValueFor("wave_count")
	self.damage = self:GetAbility():GetSpecialValueFor("wave_damage") + self:GetCaster():FindTalentValue("special_bonus_haku_4")
	self:OnIntervalThink()
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("wave_interval"))
end

function modifier_haku_needles_thinker:OnIntervalThink()
	-- shouldn't be cast more than wave_count with dynamic duration, just a fail-safe
	if self.wave_count == 0 then
		self:StartIntervalThink(-1)

		return
	end

	self.wave_count = self.wave_count - 1

	local particleName = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
	local distance = 100

	-- Center explosion
	local particle1 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( particle1, 0, self:GetParent():GetAbsOrigin() )

	local fv = self:GetCaster():GetForwardVector()
	local distance = 100

	Timers:CreateTimer(0.05,function()
	local particle2 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( particle2, 0, self:GetParent():GetAbsOrigin() + RandomVector(100) ) end)

	Timers:CreateTimer(0.1,function()
	local particle3 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( particle3, 0, self:GetParent():GetAbsOrigin() - RandomVector(100) ) end)

	Timers:CreateTimer(0.15,function()
	local particle4 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( particle4, 0, self:GetParent():GetAbsOrigin() + RandomVector(RandomInt(50,100)) ) end)

	Timers:CreateTimer(0.2,function()
	local particle5 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( particle5, 0, self:GetParent():GetAbsOrigin() - RandomVector(RandomInt(50,100)) ) end)

	self:GetParent():SetContextThink(DoUniqueString("haku_needles_wave_delay"), function()
		local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), 0, 0, false)

		for k, v in pairs(units) do
			ApplyDamage({
				victim =  v,
				attacker = self:GetCaster(),
				damage = self.damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
				ability = self:GetAbility(),
			})

			v:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_rooted", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})

			local woudns_ability = self:GetCaster():FindAbilityByName("haku_endless_wounds")
            if woudns_ability ~= nil then
			    if woudns_ability:GetLevel() > 0 then  
			    	woudns_ability:ApplyStacks(v, self:GetAbility():GetSpecialValueFor("endless_wounds_stacks"))
			    end
			end
		end

		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "hero_Crystal.freezingField.explosion", self:GetCaster())
	end, self:GetAbility():GetSpecialValueFor("delay"))
end

function modifier_haku_needles_thinker:OnRemoved()
	if not IsServer() then return end

	self:GetParent():RemoveSelf()
end
