tailed_beast_slayer = tailed_beast_slayer or class({})

LinkLuaModifier("modifier_tailed_beast_slayer", "scripts/vscripts/heroes/beasts/tailed_beast_slayer.lua", LUA_MODIFIER_MOTION_NONE)

function tailed_beast_slayer:GetIntrinsicModifierName()
	return "modifier_tailed_beast_slayer"
end

function tailed_beast_slayer:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

modifier_tailed_beast_slayer = modifier_tailed_beast_slayer or class({})

function modifier_tailed_beast_slayer:OnCreated(keys) 
    self.ability = self:GetAbility()
end

function modifier_tailed_beast_slayer:IsHidden() return true end

function modifier_tailed_beast_slayer:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_tailed_beast_slayer:OnAttackLanded(keys)
    if keys.attacker ~= self:GetParent() then return end
	
	if keys.target:IsHero() and keys.target:HasModifier("modifier_beastmaster") then
	    local counter = keys.target:FindModifierByName("modifier_beastmaster")
		self.current_stacks = counter:GetStackCount()
	end
end

function modifier_tailed_beast_slayer:GetModifierBaseDamageOutgoing_Percentage()
    local bonusDmg = 0

    if self.current_stacks == nil then
	    bonusDmg = 0
	end
	if not self.current_stacks == nil then
	    bonusDmg = self.current_stacks * 20
	end

	return bonusDmg
end

function modifier_tailed_beast_slayer:GetModifierIncomingDamage_Percentage()
	local incomingDmg = 0

    if self.current_stacks == nil then
	    incomingDmg = 0
	end
	if not self.current_stacks == nil then
	    incomingDmg = self.current_stacks * 7
	end

	return incomingDmg
end