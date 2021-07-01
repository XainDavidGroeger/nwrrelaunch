LinkLuaModifier("modifier_generic_charges", "modifiers/modifier_generic_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_naruto_shadow_clone_technique_invulnerable", "heroes/naruto/shadow_clone_technique", LUA_MODIFIER_MOTION_NONE)

naruto_shadow_clone_technique = naruto_shadow_clone_technique or class({})

function naruto_shadow_clone_technique:IsHiddenWhenStolen() return false end
function naruto_shadow_clone_technique:IsRefreshable() return true end
function naruto_shadow_clone_technique:IsStealable() return true end
function naruto_shadow_clone_technique:IsNetherWardStealable() return false end

function naruto_shadow_clone_technique:GetIntrinsicModifierName()
	return "modifier_generic_charges"
end

function naruto_shadow_clone_technique:OnSpellStart()
	if not IsServer() then return end

	local intrinsic_modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
	local image_count = intrinsic_modifier:GetStackCount() * self:GetSpecialValueFor("clones_per_charge")
	local image_out_dmg = self:GetSpecialValueFor("outgoing_damage")

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_ABSORIGIN, self:GetCaster())

	intrinsic_modifier:SetStackCount(0)
	intrinsic_modifier:CalculateCharge()
	self:GetCaster():Purge(false, true, false, false, false)
	ProjectileManager:ProjectileDodge(self:GetCaster())

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_naruto_shadow_clone_technique_invulnerable", {duration = self:GetSpecialValueFor("invuln_duration")})

	if self.illusions then
		for _, illusion in pairs(self.illusions) do
			if IsValidEntity(illusion) and illusion:IsAlive() then
				illusion:ForceKill(false)
			end
		end
	end

	self:GetCaster():SetContextThink(DoUniqueString("naga_siren_mirror_image"), function()
		-- "API Additions - Global (Server): * CreateIllusions( hOwner, hHeroToCopy, hModifierKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace ) Note: See script_help2 for supported modifier keys"
		self.illusions = CreateIllusions(self:GetCaster(), self:GetCaster(), {
			outgoing_damage 			= image_out_dmg,
			incoming_damage				= self:GetSpecialValueFor("incoming_damage"),
			bounty_base					= self:GetCaster():GetIllusionBounty(),
			bounty_growth				= nil,
			outgoing_damage_structure	= nil,
			outgoing_damage_roshan		= nil,
			duration					= self:GetSpecialValueFor("illusion_duration")
		}, image_count, self:GetCaster():GetHullRadius(), true, true)

		for i = 1, #self.illusions do
			local illusion = self.illusions[i]
			local pos = self:GetCaster():GetAbsOrigin() + RandomVector(self:GetSpecialValueFor("spawn_radius"))
			FindClearSpaceForUnit(illusion, pos, true)
			local part2 = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_riptide_foam.vpcf", PATTACH_ABSORIGIN, illusion)
			ParticleManager:ReleaseParticleIndex(part2)
		end

		ParticleManager:DestroyParticle(pfx, false)
		ParticleManager:ReleaseParticleIndex(pfx)

		self:GetCaster():Stop()

		return nil
	end, self:GetSpecialValueFor("invuln_duration"))

	self:GetCaster():EmitSound("Hero_NagaSiren.MirrorImage")
end

modifier_naruto_shadow_clone_technique_invulnerable = modifier_naruto_shadow_clone_technique_invulnerable or class({})

function modifier_naruto_shadow_clone_technique_invulnerable:IsHidden() return true end

function modifier_naruto_shadow_clone_technique_invulnerable:CheckState() return {
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_STUNNED] = true,
	-- [MODIFIER_STATE_OUT_OF_GAME] = true,
} end
