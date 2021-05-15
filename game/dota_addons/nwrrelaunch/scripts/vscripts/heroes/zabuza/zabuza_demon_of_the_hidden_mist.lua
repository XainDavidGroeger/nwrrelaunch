zabuza_demon_of_the_hidden_mist = zabuza_demon_of_the_hidden_mist or class({})

LinkLuaModifier("modifier_demon_mark", "scripts/vscripts/heroes/zabuza/modifiers/modifier_demon_mark.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demon_unkillable", "scripts/vscripts/heroes/zabuza/modifiers/modifier_demon_unkillable.lua", LUA_MODIFIER_MOTION_NONE)

function zabuza_demon_of_the_hidden_mist:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function zabuza_demon_of_the_hidden_mist:GetCastRange(location, target)
	return self:GetSpecialValueFor("range")
end

function zabuza_demon_of_the_hidden_mist:CanBeReflected(bool, target)
    if bool == true then
        if target:TriggerSpellReflect(self) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function zabuza_demon_of_the_hidden_mist:ProcsMagicStick()
	return true
end

function zabuza_demon_of_the_hidden_mist:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	
	self:PlaySound()
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(true, target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(self) then return end
	
	target:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_demon_mark", -- modifier name
                { duration = duration } -- kv
            )
			
    caster:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_demon_unkillable", -- modifier name
                { duration = duration } -- kv
            )
	--keys.ability.markedEnemy = keys.target
	
	self:PlayEffect(target, duration)
	
	EmitSoundOn("Hero_Visage.GraveChill.Target", target)
	
	Timers:CreateTimer(0.0, function ()
	    if distance >= 1500 or not target:IsAlive() then
	    	caster:RemoveModifierByName("modifier_demon_unkillable")
	    	target:RemoveModifierByName("modifier_demon_mark")
	    end
		
		return 0.03
	end)
end

function zabuza_demon_of_the_hidden_mist:PlayEffect(target, duration)
    local demon_mark_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(demon_mark_particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	
	Timers:CreateTimer(duration, function ()
	    ParticleManager:DestroyParticle(demon_mark_particle, true)
		ParticleManager:ReleaseParticleIndex(demon_mark_particle)
	end)
end

function zabuza_demon_of_the_hidden_mist:PlaySound()
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("zabuza_ult", self:GetCaster())
	elseif random == 2 then
		EmitSoundOn("zabuza_ult_2", self:GetCaster())
	end
	
	EmitSoundOn("zabuza_demon_talking", self:GetCaster())
end