kisame_bunshin_water_prison = class({})

function kisame_bunshin_water_prison:Precache( context )
PrecacheResource( "soundfile", "soundevents/kisame_bunshin_water_prison.vsndevts", context )
PrecacheResource( "particle", "particles/units/heroes/kisame/bunshin_prison_new.vpcf", context )
end

function kisame_bunshin_water_prison:GetCooldown(iLevel)
return self.BaseClass.GetCooldown(self, iLevel)
end

function kisame_bunshin_water_prison:GetCastRange(location, target)
return self:GetSpecialValueFor("range")
end

function kisame_bunshin_water_prison:GetChannelTime()
return self:GetSpecialValueFor("channel_time")
end

function kisame_bunshin_water_prison:CanBeReflected(bool, target)
    if bool == true then
        if target:TriggerSpellReflect(self) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end


function kisame_bunshin_water_prison:OnSpellStart()
    -- load data
    local duration = self:GetSpecialValueFor("channel_time")
	self.target = self:GetCursorTarget()
    self.caster = self:GetCaster()
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if self.target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(false, self.target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if self.target:TriggerSpellAbsorb(self) then return end
	
	self.target:AddNewModifier(
        self.caster, -- player source
        self, -- ability source
        "modifier_stunned", -- modifier name
        { duration = duration } -- kv
    )
    
    self.caster:EmitSound("kisame_bunshin_water_prison")

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_7, 1)
    self:GetCursorTarget():StartGestureWithPlaybackRate(ACT_DOTA_DISABLED, 1)
    
    self.waterPrison_particle = ParticleManager:CreateParticle("particles/units/heroes/kisame/bunshin_prison_new.vpcf", PATTACH_ABSORIGIN, self:GetCursorTarget())
    ParticleManager:SetParticleControl(self.waterPrison_particle, 0, self:GetCursorTarget():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.waterPrison_particle, 1, self:GetCursorTarget():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.waterPrison_particle, 2, Vector(2, 10, 10))
    ParticleManager:SetParticleControl(self.waterPrison_particle, 3, self:GetCursorTarget():GetAbsOrigin())
end

function kisame_bunshin_water_prison:OnChannelFinish(bInterrupted)
    local target = self.target
    local caster = self.caster
    
    if bInterrupted then
        target:RemoveModifierByName("modifier_stunned")
        
        local sound_cast = "kisame_bunshin_water_prison"
        if caster ~= nil then
            StopSoundOn(sound_cast, caster)
        end
        
        target:RemoveGesture(ACT_DOTA_DISABLED)
     
        if caster ~= nil then
            caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_7)
        end
        
        ParticleManager:DestroyParticle(self.waterPrison_particle, true)
        ParticleManager:ReleaseParticleIndex(self.waterPrison_particle)
    end
    
    target:RemoveModifierByName("modifier_stunned")
    
    local sound_cast = "kisame_bunshin_water_prison"
    StopSoundOn(sound_cast, caster)
    
    target:RemoveGesture(ACT_DOTA_DISABLED)
    if caster ~= nil then
        caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_7)
    end
    
	if self.waterPrison_particle ~= nil then
        ParticleManager:DestroyParticle(self.waterPrison_particle, true)
        ParticleManager:ReleaseParticleIndex(self.waterPrison_particle)
	end
end
