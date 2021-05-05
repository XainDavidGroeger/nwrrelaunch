LinkLuaModifier("modifier_haku_mirror_caster", "heroes/haku/ice_mirrors", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_mirror_mirror", "heroes/haku/ice_mirrors", LUA_MODIFIER_MOTION_NONE)

haku_ice_mirrors = haku_ice_mirrors or class({})

function haku_ice_mirrors:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("haku_mirrors_cast")

	return true
end

function haku_ice_mirrors:OnSpellStart()
	if not IsServer() then return end

	local attack_min = self:GetSpecialValueFor("attack_min") + self:GetCaster():FindTalentValue("special_bonus_haku_5")	
	local attack_max = self:GetSpecialValueFor("attack_max") + self:GetCaster():FindTalentValue("special_bonus_haku_5")
	local health = self:GetSpecialValueFor("hp")
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local count = self:GetSpecialValueFor("count")
	self.mirrors = {}

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_haku_mirror_caster", {duration = duration})
	self:GetCaster():EmitSound("Hero_Ancient_Apparition.IceVortex")

	local r = radius / 2

	GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(), radius, true)

	for i = 1, count do
		local posX = self:GetCaster():GetAbsOrigin().x + r * math.cos((math.pi * 2 / count) * i)
		local posY = self:GetCaster():GetAbsOrigin().y + r * math.sin((math.pi * 2 / count) * i)
		local mirror_position = Vector(posX, posY, 0)

		local mirror = CreateUnitByName("npc_haku_mirror", mirror_position, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())

		if mirror then
			mirror:SetHullRadius(48)
			FindClearSpaceForUnit(mirror, mirror_position, false)
			mirror:SetBaseDamageMin(attack_min)
			mirror:SetBaseDamageMax(attack_max)
			mirror:SetMaxHealth(health)
			mirror:SetHealth(health)
			mirror:SetOwner(self:GetCaster())
			mirror:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)

			mirror:AddNewModifier(mirror, self, "modifier_haku_mirror_mirror", {duration = duration})
			mirror:AddNewModifier(mirror, self, "modifier_kill", {duration = duration})

			if self:GetLevel() == 2 then
				mirror:CreatureLevelUp(1)
			end

			if self:GetLevel() == 3 then
				mirror:CreatureLevelUp(2)
			end

			local endless_wounds_ability = self:GetCaster():FindAbilityByName("haku_endless_wounds")

			if endless_wounds_ability:GetLevel() > 0 then
				mirror:AddNewModifier(self:GetCaster(), endless_wounds_ability, "modifier_haku_endless_needles_caster",{})
			end

			table.insert(self.mirrors, mirror)
		end
	end
end

modifier_haku_mirror_caster = modifier_haku_mirror_caster or class({})

function modifier_haku_mirror_caster:IsHidden() return true end

function modifier_haku_mirror_caster:CheckState() return {
	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	[MODIFIER_STATE_STUNNED] = true,
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_OUT_OF_GAME] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
} end

function modifier_haku_mirror_caster:OnCreated()
	if not IsServer() then return end

	self:GetParent():AddNoDraw()
end

function modifier_haku_mirror_caster:OnRemoved()
	if not IsServer() then return end

	self:GetParent():RemoveNoDraw()
end

modifier_haku_mirror_mirror = modifier_haku_mirror_mirror or class({})

function modifier_haku_mirror_mirror:IsHidden() return true end

function modifier_haku_mirror_mirror:DeclareFunctions() return {
	MODIFIER_EVENT_ON_DEATH,
} end

function modifier_haku_mirror_mirror:CheckState() return {
	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
} end

function modifier_haku_mirror_mirror:OnCreated()
	if not IsServer() then return end

	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/haku/wyvern_cold_embrace_buff.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.pfx, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.pfx, 2, self:GetParent():GetAbsOrigin())
end

function modifier_haku_mirror_mirror:OnDeath(keys)
	if not IsServer() then return end
	if keys.unit ~= self:GetParent() then return end

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end

	local explosion = ParticleManager:CreateParticle("particles/units/heroes/haku/mirror_destroy.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(explosion, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(explosion)

	self:GetParent():Destroy()

	if self:GetRemainingTime() <= 0 then
		return
	end

	local should_die = true

	for k, v in pairs(self:GetAbility().mirrors) do
		if not v:IsNull() then
			if v:IsAlive() then
				should_die = false
				break
			end
		end
	end

	if should_die and keys.attacker then
		self:GetAbility():GetCaster():Kill(nil, keys.attacker)
	end
end
