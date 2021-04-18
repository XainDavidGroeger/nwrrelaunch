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


function kisame_bunshin_water_prison:OnSpellStart()
    -- load data
    local duration = self:GetSpecialValueFor("channel_time")
	self.target = self:GetCursorTarget()
    self.caster = self:GetCaster()
	
	self:GetCursorTarget():AddNewModifier(
        self:GetCaster(), -- player source
        self, -- ability source
        "modifier_stunned", -- modifier name
        { duration = duration } -- kv
    )
    
    local sound_cast = "kisame_bunshin_water_prison"
    EmitSoundOn(sound_cast, self:GetCaster())
    
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
    
    ParticleManager:DestroyParticle(self.waterPrison_particle, true)
    ParticleManager:ReleaseParticleIndex(self.waterPrison_particle)
end
