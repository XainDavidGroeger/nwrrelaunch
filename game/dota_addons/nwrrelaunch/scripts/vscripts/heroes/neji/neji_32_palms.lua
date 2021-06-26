neji_32_palms = neji_32_palms or class({})
LinkLuaModifier("modifier_32_palms_caster", "heroes/neji/neji_32_palms", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_32_palms_debuff", "heroes/neji/neji_32_palms", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_32_palms_debuff_silence", "heroes/neji/neji_32_palms", LUA_MODIFIER_MOTION_NONE)

function neji_32_palms:Precache( context )
    PrecacheResource( "soundfile", "soundevents/heroes/neji/neji_64_cast.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/neji/neji_64_channel.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/neji/neji_64_cast_talking.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/neji/neji_64_finish_talking.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/neji/neji_64_finish_sound.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/neji/neji_64_hit.vsndevts", context )

    PrecacheResource( "particle", "particles/generic_gameplay/generic_silence.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/ulti/bagum_projected.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/ulti/64_palm_finish.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/ulti/ulti_images.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/ulti/2_ulti_images.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/ulti/numbers_32.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/ulti/numbers_64.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/ulti/numbers_128.vpcf", context )
end

function neji_32_palms:GetAbilityTextureName()
	return "neji_32_palms"
end

function neji_32_palms:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function neji_32_palms:ProcsMagicStick()
    return true
end

function neji_32_palms:OnSpellStart()

    self.ability = self
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()

    self.caster:EmitSound("neji_64_cast")
    self.caster:EmitSound("neji_64_cast_talking")

    -- add modifier_32_palms_caster to caster
    self.caster:AddNewModifier(self.caster, self.ability, "modifier_32_palms_caster", {})
    -- add modifier_32_palms_debuff to target
    self.target:AddNewModifier(self.caster, self.ability, "modifier_32_palms_debuff", {})

    local distance = self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()
		
	self.ability.images_particle = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/2_ulti_images.vpcf", PATTACH_ABSORIGIN, self.caster)
	ParticleManager:SetParticleControl(self.ability.images_particle, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.ability.images_particle, 1, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.ability.images_particle, 3, self.target:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.ability.images_particle, 4, self.caster:GetForwardVector() * distance:Length2D() )
  
end

function neji_32_palms:OnChannelFinish(bInterrupted)
    self.ability = self
    self.caster = self:GetCaster()

    self.caster:RemoveModifierByName("modifier_32_palms_caster")
    self.target:RemoveModifierByName("modifier_32_palms_debuff")

    if bInterrupted == true then
        self.caster:StopSound("neji_64_cast_talking")
    end

    if bInterrupted == false then
        self.target:EmitSound("neji_64_finish_sound")
        self.target:EmitSound("neji_64_finish_talking")
        self.target_bagum = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/64_palm_finish.vpcf",PATTACH_ABSORIGIN , self.target)
        ParticleManager:SetParticleControl( self.target_bagum, 0, self.target:GetAbsOrigin()) -- Origin
        local silence_duration = self.ability:GetSpecialValueFor("silence_duration") + self:GetCaster():FindTalentValue("special_bonus_neji_4")

        if self.target:IsMagicImmune() == false then
            self.target:AddNewModifier(self.caster, self.ability, "modifier_32_palms_debuff_silence", {duration = silence_duration})
        end

    end
end


modifier_32_palms_caster = modifier_32_palms_caster or class({})

function modifier_32_palms_caster:IsHidden() return true end

function modifier_32_palms_caster:OnCreated()
	if not IsServer() then return end

    self.ability = self:GetAbility()

    self.bagum = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/bagum_projected.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(self.bagum, 0, self:GetCaster():GetAbsOrigin()) -- Origin

	self.damage = self:GetAbility():GetSpecialValueFor("damage")

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_6, 1.5)

end

function modifier_32_palms_caster:OnDestroy()
	if not IsServer() then return end

	ParticleManager:DestroyParticle(self.bagum, true)
    ParticleManager:DestroyParticle(self.ability.images_particle, true)
    self:GetParent():RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_6)
end


modifier_32_palms_debuff = modifier_32_palms_debuff or class({})

function modifier_32_palms_debuff:IsDebuff() return true end

function modifier_32_palms_debuff:CheckState()
    local state = {
            [MODIFIER_STATE_STUNNED] = true,
        }
    
    return state
end

function modifier_32_palms_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_32_palms_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_32_palms_debuff:OnCreated()
    self.hits_count = 0
    self.interval_count = 1
    self.intervals = {0.4, 0.4, 0.17, 0.085, 0.02085, 0.01042, -1}
    self.hits = {2,4,8,16,32,64}
    --TODO: fix VFX, vector belove is for that
    self.vfx_v_1 = {
        Vector(0,2,0),
        Vector(0,0,0),
        Vector(0,4,0),
        Vector(0,8,0),
        Vector(0,1,0),
        Vector(0,3,0),
        Vector(0,6,0),
    }
    self.vfx_v_2 = {
        Vector(0,0,0),
        Vector(0,0,0),
        Vector(0,0,0),
        Vector(0,0,0),
        Vector(1,6,0),
        Vector(1,2,0),
        Vector(1,4,0),
    }
    self.vfx_v_color = {
        Vector(156,156,0),
        Vector(156,156,0),
        Vector(156,156,0),
        Vector(156,156,0),
        Vector(156,156,0),
        Vector(156,156,0),
        Vector(239,145,38),
        Vector(255,0,0),
    }

    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.parent = self:GetParent()
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.mana_burned_per_attack_perc = self.ability:GetSpecialValueFor("mana_burned_per_attack_perc")
    self.one_palm_damage = self.damage / 64


	if not IsServer() then return end
    self.mana_burn_damage_table = {
        victim = self.parent,
        attacker = self.caster,
        damage_type = self.ability:GetAbilityDamageType(),
        ability = self.ability
    }

    self.damage_table = {
        victim = self.parent,
        attacker = self.caster,
        damage = self.one_palm_damage,
        damage_type = self.ability:GetAbilityDamageType(),
        ability = self.ability
    }

    self:GetParent():StartGesture(ACT_DOTA_FLAIL)

	self:StartIntervalThink(self.intervals[self.interval_count])
end

function modifier_32_palms_debuff:OnDestroy() 
    if not IsServer() then return end
    self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
end

function modifier_32_palms_debuff:OnIntervalThink()
    ApplyDamage(self.damage_table)
    self.hits_count = self.hits_count + 1

    --Sound
    self.parent:EmitSound("neji_64_hit")

    --Manaburn per hit
    if self.caster:HasModifier("modifier_neji_byakugan_buff") then
        
        local mana = self.parent:GetMana()
        local reduce_mana_amount = self.parent:GetMaxMana() / 100 * self.mana_burned_per_attack_perc
        local new_mana = mana - reduce_mana_amount
        local damage_percent = 100 --TODO: This should be KV
    
        self.parent:SetMana(new_mana)
    
        local damage = reduce_mana_amount / 100 * damage_percent
        self.mana_burn_damage_table.damage = damage
        ApplyDamage(self.mana_burn_damage_table) --Manaburn damage

        --Manaburn overhead effect
        SendOverheadEventMessage(
            nil,
            OVERHEAD_ALERT_MANA_LOSS,
            self:GetParent(),
            reduce_mana_amount,
            self:GetCaster():GetPlayerOwner()
        )
    end

    if self.hits_count == self.hits[self.interval_count] then
        self.interval_count = self.interval_count + 1
        self:StartIntervalThink(-1)
        self:StartIntervalThink(self.intervals[self.interval_count])

        SendOverheadEventMessage(
            nil,
            OVERHEAD_ALERT_DAMAGE,
            self:GetParent(),
            self.hits_count,
            self:GetCaster():GetPlayerOwner()
        )

    end
end


-- Blast Off Silence modifier
modifier_32_palms_debuff_silence = modifier_32_palms_debuff_silence or class({})

function modifier_32_palms_debuff_silence:IsHidden() return false end
function modifier_32_palms_debuff_silence:IsPurgable() return true end
function modifier_32_palms_debuff_silence:IsDebuff() return true end

function modifier_32_palms_debuff_silence:CheckState()
	local state = {[MODIFIER_STATE_SILENCED] = true}
	return state
end

function modifier_32_palms_debuff_silence:GetEffectName()
	return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_32_palms_debuff_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end