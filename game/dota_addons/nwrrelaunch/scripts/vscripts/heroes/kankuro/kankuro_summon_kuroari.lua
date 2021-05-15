kankuro_summon_kuroari = kankuro_summon_kuroari or class({})

function kankuro_summon_kuroari:GetAbilityTextureName()
	return "kankuro_summon_kuroari"
end

function kankuro_summon_kuroari:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function kankuro_summon_kuroari:GetCastRange(location, target)
	local castrangebonus = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_kankuro_2")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	castrangebonus = 125
	    end
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function kankuro_summon_kuroari:CanBeReflected(bool, target)
    if bool == true then
        if target:TriggerSpellReflect(self) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
        ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function kankuro_summon_kuroari:ProcsMagicStick()
    return true
end

function kankuro_summon_kuroari:OnSpellStart()
    local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local caster_location = caster:GetAbsOrigin() 
	local target_location = target:GetAbsOrigin()
	local player = caster:GetPlayerOwnerID()
	local ability = self
	
	    --[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(false, target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(self) then return end

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


