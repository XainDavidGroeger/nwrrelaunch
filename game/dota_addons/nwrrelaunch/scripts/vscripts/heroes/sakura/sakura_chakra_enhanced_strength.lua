sakura_chakra_enhanced_strength = sakura_chakra_enhanced_strength or class({})
LinkLuaModifier("modifier_sakura_strength_caster", "heroes/sakura/sakura_chakra_enhanced_strength", LUA_MODIFIER_MOTION_NONE)

function sakura_chakra_enhanced_strength:Precache( context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sakura/sakura_strength_impact.vsndevts", context )

    PrecacheResource( "particle", "particles/units/heroes/hero_razor/razor_ambient_g.vpcf", context )
    PrecacheResource( "particle", "particles/generic_gameplay/generic_purge.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/razor/razor_punctured_crest/razor_helmet_blade_ambient_a.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_razor/razor_base_attack_impact_b.vpcf", context )
end

function sakura_chakra_enhanced_strength:GetAbilityTextureName()
	return "sakura_chakra_enhanced_strength"
end

function sakura_chakra_enhanced_strength:GetIntrinsicModifierName()
	return "modifier_sakura_strength_caster"
end

modifier_sakura_strength_caster = modifier_sakura_strength_caster or class({})

function modifier_sakura_strength_caster:IsHidden() return false end
function modifier_sakura_strength_caster:IsBuff() return true end

function modifier_sakura_strength_caster:OnCreated()
	if not IsServer() then return end
    self.ability = self:GetAbility()
end


function modifier_sakura_strength_caster:DeclareFunctions() return {
	MODIFIER_EVENT_ON_ATTACK_LANDED,
} end

function modifier_sakura_strength_caster:OnAttackLanded(params)
	if not IsServer() then return end

	if params.attacker == self:GetCaster() then

		if params.target:IsBuilding() then
			return nil
		end

		if self:GetStackCount() < 3 then
			self:SetStackCount(self:GetStackCount() + 1)
		else

			self.damage = self.ability:GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_sakura_1")
			self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")

			-- apply stun
			params.target:AddNewModifier(params.attacker, self.ability, "modifier_stunned", {duration = self.stun_duration})
			
			if params.target:IsHero() then
				ApplyDamage({attacker = params.attacker, victim = params.target, ability = self.ability, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL})		
			else
				ApplyDamage({attacker = params.attacker, victim = params.target, ability = self.ability, damage = self.damage * 2, damage_type = DAMAGE_TYPE_PHYSICAL})	
			end
			PopupDamage(params.target, self.damage)

			params.target:EmitSound("sakura_strength_impact")

			self:SetStackCount(0)
		end
	end
end