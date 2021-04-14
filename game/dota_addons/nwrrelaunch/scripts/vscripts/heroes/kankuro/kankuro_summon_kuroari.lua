kankuro_summon_kuroari = kankuro_summon_kuroari or class({})

function kankuro_summon_kuroari:GetAbilityTextureName()
	return "kankuro_summon_kuroari"
end

function kankuro_summon_kuroari:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function kankuro_summon_kuroari:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_kankuro_2"):GetLevel() > 0 then
		castrangebonus = 125
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function kankuro_summon_kuroari:OnSpellStart()

    local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local caster_location = caster:GetAbsOrigin() 
	local target_location = target:GetAbsOrigin()
	local player = caster:GetPlayerOwnerID()
	local ability = self

	-- Ability variables
	local puppet_duration = ability:GetLevelSpecialValueFor("puppet_duration", ability:GetLevel() - 1) 

	-- Modifiers
	-- Apply the stun duration
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = puppet_duration})

	--Creates the Puppet next to the Target
	local kuroari = CreateUnitByName("npc_kuroari", target_location + RandomVector(100), true, caster, caster, caster:GetTeamNumber())


	kuroari:SetMaxHealth(10000)
	kuroari:SetHealth(10000)

	--Remove Puppet
	Timers:CreateTimer(puppet_duration,function()
		kuroari:RemoveSelf()
	end)

end


