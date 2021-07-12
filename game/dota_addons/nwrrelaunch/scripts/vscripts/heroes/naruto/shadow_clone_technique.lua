LinkLuaModifier("modifier_generic_charges", "modifiers/modifier_generic_charges", LUA_MODIFIER_MOTION_NONE)

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

	local count = 0
	local intrinsic_modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
	local image_count = intrinsic_modifier:GetStackCount() * self:GetSpecialValueFor("clones_per_charge")

	intrinsic_modifier:SetStackCount(0)
	intrinsic_modifier:CalculateCharge()

	self:GetCaster():SetContextThink(DoUniqueString("naruto_shadow_clone_technique"), function()
		-- "API Additions - Global (Server): * CreateIllusions( hOwner, hHeroToCopy, hModifierKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace ) Note: See script_help2 for supported modifier keys"
		self.illusion = CreateIllusions(self:GetCaster(), self:GetCaster(), {
			outgoing_damage 			= self:GetSpecialValueFor("outgoing_damage"),
			incoming_damage				= self:GetSpecialValueFor("incoming_damage"),
			bounty_base					= self:GetCaster():GetIllusionBounty(),
			bounty_growth				= nil,
			outgoing_damage_structure	= nil,
			outgoing_damage_roshan		= nil,
			duration					= self:GetSpecialValueFor("illusion_duration")
		}, 1, self:GetCaster():GetHullRadius(), true, true)

		count = count + 1

		local illusion = self.illusion[1]
		local pos = self:GetCaster():GetAbsOrigin() + RandomVector(RandomInt(100, self:GetSpecialValueFor("spawn_radius")))

		FindClearSpaceForUnit(illusion, pos, true)

		local part2 = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_riptide_foam.vpcf", PATTACH_ABSORIGIN, illusion)
		ParticleManager:ReleaseParticleIndex(part2)

		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_ABSORIGIN, illusion)
		ParticleManager:DestroyParticle(pfx, false)
		ParticleManager:ReleaseParticleIndex(pfx)

		if count >= image_count then
			return nil
		else
			return self:GetSpecialValueFor("delay_between_illusions")
		end

	end, 0.0)

	self:GetCaster():EmitSound("Hero_NagaSiren.MirrorImage")
end
