haku_endless_wounds = haku_endless_wounds or class({})


LinkLuaModifier("modifier_haku_endless_needles_victim", "heroes/haku/endless_wounds.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_endless_needles_caster", "heroes/haku/endless_wounds.lua", LUA_MODIFIER_MOTION_NONE)

function haku_endless_wounds:GetAbilityTextureName()
	return "haku_endless_wounds"
end

function haku_endless_wounds:GetIntrinsicModifierName()
	return "modifier_haku_endless_needles_caster"
end

function haku_endless_wounds:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end


modifier_haku_endless_needles_caster = modifier_haku_endless_needles_caster or class({})

function modifier_haku_endless_needles_caster:IsHidden() return true end

function modifier_haku_endless_needles_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_haku_endless_needles_caster:OnCreated()
	-- Ability properties
	self.caster = self:GetParent()
	self.ability = self:GetAbility()
	self.stacks = 0
end

function modifier_haku_endless_needles_caster:OnAttackLanded( keys )

		local target = keys.target
		local caster = keys.target

		self.stacks_per_attack = self:GetAbility():GetSpecialValueFor("stacks_per_attack")
		self.duration = self:GetAbility():GetSpecialValueFor("duration")
		self.threshold = self:GetAbility():GetSpecialValueFor("threshold")
		self.stack_modifier = "modifier_haku_endless_needles_victim"

		if target:HasModifier(self.stack_modifier) then
			local stacks = target:GetModifierStackCount("modifier_haku_endless_needles_victim", self:GetAbility())
			if (stacks + self.stacks_per_attack) <= self.threshold then
				target:SetModifierStackCount(self.stack_modifier,self.ability,stacks + self.stacks_per_attack)
			else
				target:SetModifierStackCount(self.stack_modifier,self.ability,self.threshold)
			end
		else 
			modifier_debuff = target:AddNewModifier(self.caster, self.ability, "modifier_haku_endless_needles_victim", {duration = self.duration})
			target:SetModifierStackCount(self.stack_modifier, self.ability, self.stacks_per_attack)
		end
end

modifier_haku_endless_needles_victim = modifier_haku_endless_needles_victim or class({})

function modifier_haku_endless_needles_victim:IsHidden() return false end
function modifier_haku_endless_needles_victim:IsPurgable() return true end
function modifier_haku_endless_needles_victim:IsDebuff() return true end

function modifier_haku_endless_needles_victim:OnCreated(keys)
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self:SetStackCount(self:GetStackCount())
end

function modifier_haku_endless_needles_victim:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_haku_endless_needles_victim:GetModifierMoveSpeedBonus_Percentage()
	local value = 0

	if self.caster:FindAbilityByName("special_bonus_haku_1") == nil then
		if self.caster:GetOwner():FindAbilityByName("special_bonus_haku_1"):GetLevel() > 0 then
			value = 0.25
		end
	else
		if self.caster:FindAbilityByName("special_bonus_haku_1"):GetLevel() > 0 then
			value = 0.25
		end
	end
	
    return  self:GetStackCount() * (-1 - value)
end