LinkLuaModifier("modifier_itachi_crow_bunshin", "heroes/itachi/dust_crow_genjutsu", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_itachi_crow_bunshin_dummy", "heroes/itachi/dust_crow_genjutsu", LUA_MODIFIER_MOTION_NONE)

itachi_dust_crow_genjustsu = itachi_dust_crow_genjustsu or class({})

function itachi_dust_crow_genjustsu:Precache(context)
	PrecacheResource("soundfile",  "soundevents/itachi_crows.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/hero_pick.vsndevts", context)

	PrecacheResource("particle",   "particles/world_creature_fx/crows.vpcf", context)
end

function itachi_dust_crow_genjustsu:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level) -- + self:GetCaster():FindTalentValue("special_bonus_itachi_2")
end

function itachi_dust_crow_genjustsu:ProcsMagicStick()
    return true
end

function itachi_dust_crow_genjustsu:OnSpellStart()
	if not IsServer() then return end

	local caster_pos = self:GetCaster():GetAbsOrigin()
	local point = self:GetCursorPosition()
	local difference = point - caster_pos
	local range = self:GetSpecialValueFor("blink_range")

	self:GetCaster():AddNoDraw()

	if difference:Length2D() > range then
		point = caster_pos + (point - caster_pos):Normalized() * range
	end

	FindClearSpaceForUnit(self:GetCaster(), point, false)
	ProjectileManager:ProjectileDodge(self:GetCaster())

	self:GetCaster():RemoveNoDraw()

	local illusions = CreateIllusions(self:GetCaster(), self:GetCaster(), {
		outgoing_damage = self:GetSpecialValueFor("illusion_outgoing_damage"),
		incoming_damage	= self:GetSpecialValueFor("illusion_ingoing_damage"),
		duration		= self:GetSpecialValueFor("illusion_duration") + self:GetCaster():FindTalentValue("special_bonus_itachi_2")
	}, 1, self:GetCaster():GetHullRadius(), true, true)

	for _, illusion in pairs(illusions) do
		illusion:SetForwardVector(self:GetCaster():GetForwardVector())
		FindClearSpaceForUnit(illusion, caster_pos, false)
		illusion:AddNewModifier(self:GetCaster(), self, "modifier_itachi_crow_bunshin", {})

--		illusion:SetContextThink(DoUniqueString("itachi_illusion"), function()

--			return nil
--		end, FrameTime())
	end
end

modifier_itachi_crow_bunshin = modifier_itachi_crow_bunshin or class({})

function modifier_itachi_crow_bunshin:IsHidden() return true end

function modifier_itachi_crow_bunshin:OnCreated()
	if not IsServer() then return end

	self.remove_pfx = false

end

function modifier_itachi_crow_bunshin:OnDestroy()
	if not IsServer() then return end

	self:GetParent():EmitSound("itachi_crows")
	self.crows = ParticleManager:CreateParticle(
		"particles/world_creature_fx/crows.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		self:GetAbility():GetCaster()
	)
	ParticleManager:SetParticleControl(self.crows, 0, self:GetParent():GetAbsOrigin())
	print(self:GetParent():GetAbsOrigin())
	-- ParticleManager:SetParticleControlEnt(int_1, int_2, handle_3, int_4, string_5, Vector_6, bool_7)

end

-- modifier_itachi_crow_bunshin_dummy = modifier_itachi_crow_bunshin_dummy or class({})

-- function modifier_itachi_crow_bunshin_dummy:OnCreated()
-- 	if not IsServer() then return end

-- 	self:GetParent():EmitSound("itachi_crows")
-- 	self.crows = ParticleManager:CreateParticle("particles/world_creature_fx/crows.vpcf", PATTACH_ABSORIGIN, self:GetParent())
-- end

-- function modifier_itachi_crow_bunshin_dummy:OnRemoved()
-- 	if not IsServer() then return end

-- 	if self.pfx then
-- 		ParticleManager:DestroyParticle(self.crows, false)
-- 		ParticleManager:ReleaseParticleIndex(self.crows)
-- 	end
-- end
