neji_32_palms = neji_32_palms or class({})
LinkLuaModifier("modifier_32_palms_caster", "heroes/neji/neji_32_palms", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_32_palms_debuff", "heroes/neji/neji_32_palms", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_32_palms_debuff_silence", "heroes/neji/neji_32_palms", LUA_MODIFIER_MOTION_NONE)


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

	Timers:CreateTimer(1.33, function()
        if self.caster:HasModifier("modifier_32_palms_caster") then
            self.number_32 = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/numbers_32.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
            ParticleManager:SetParticleControl(self.number_32, 1, Vector(0, 1, 0))
            ParticleManager:SetParticleControl(self.number_32, 2, Vector(0, 6, 0))
        end

		Timers:CreateTimer(1.33, function()
            
			ParticleManager:DestroyParticle(self.number_32, false)

            if self.caster:HasModifier("modifier_32_palms_caster") then
                self.number_64 = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/numbers_64.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
                ParticleManager:SetParticleControl(self.number_64, 1, Vector(0, 3, 0))
                ParticleManager:SetParticleControl(self.number_64, 2, Vector(0, 2, 0))
            end
	
			Timers:CreateTimer(1.33, function()
				ParticleManager:DestroyParticle(self.number_64, false)
                if self.caster:HasModifier("modifier_32_palms_caster") then
                    self.number_128 = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/numbers_128.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
				    ParticleManager:SetParticleControl(self.number_128, 1, Vector(0, 6, 0))
				    ParticleManager:SetParticleControl(self.number_128, 2, Vector(0, 4, 0))
                end
				
			end)
		end)
	end)

	Timers:CreateTimer(5.0, function()
		ParticleManager:DestroyParticle(self.number_32, false)
		ParticleManager:DestroyParticle(self.number_64, false)
		ParticleManager:DestroyParticle(self.number_128, false)
	end)
  
end

function neji_32_palms:OnChannelFinish(bInterrupted)
    self.ability = self
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()

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
        self.target:AddNewModifier(self.caster, self.ability, "modifier_32_palms_debuff_silence", {duration = silence_duration})
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
end

function modifier_32_palms_caster:OnDestroy()
	ParticleManager:DestroyParticle(self.bagum, true)
    ParticleManager:DestroyParticle(self.ability.images_particle, true)
    self:GetParent():RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_6)
end


modifier_32_palms_debuff = modifier_32_palms_debuff or class({})

function modifier_32_palms_debuff:IsDebuff() return true end

function modifier_32_palms_debuff:OnCreated()
	if not IsServer() then return end

    self:GetParent():StartGesture(ACT_DOTA_FLAIL)
    self.interval_count = 1

    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.one_palm_damage = self.damage / 62

    self.interval_time = 0.66


    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_6, 1.5)
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.one_palm_damage,
        damage_type = self:GetAbility():GetAbilityDamageType()
    })
    PopupManaDrain(self:GetParent(),math.floor(1))
    self:GetParent():EmitSound("neji_64_hit")
    burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
    Timers:CreateTimer(0.33, function()
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.one_palm_damage,
            damage_type = self:GetAbility():GetAbilityDamageType()
        })
        burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
        PopupManaDrain(self:GetParent(),math.floor(2))
        self:GetParent():EmitSound("neji_64_hit")
        self:GetCaster():RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_6)
    end)

	self:StartIntervalThink(0.66)
end

function modifier_32_palms_debuff:OnDestroy() 
    self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
end

function modifier_32_palms_debuff:OnIntervalThink()

    self.interval_count = self.interval_count + 1
    self:GetCaster():RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_6)


    if self.interval_count == 2 then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_6, 1.5)
        PopupManaDrain(self:GetParent(),math.floor(3))
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.one_palm_damage,
            damage_type = self:GetAbility():GetAbilityDamageType()
        })
        burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
        self:GetParent():EmitSound("neji_64_hit")
        Timers:CreateTimer(0.33, function()
            ApplyDamage({
                victim = self:GetParent(),
                attacker = self:GetCaster(),
                damage = self.one_palm_damage,
                damage_type = self:GetAbility():GetAbilityDamageType()
            })
            burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
            PopupManaDrain(self:GetParent(),math.floor(4))
            self:GetParent():EmitSound("neji_64_hit")
        end)
    end

    if self.interval_count == 3 then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_6, 2)
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.one_palm_damage,
            damage_type = self:GetAbility():GetAbilityDamageType()
        })
        burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
        self:GetParent():EmitSound("neji_64_hit")
        PopupManaDrain(self:GetParent(),math.floor(5))
        damageAfterXSecondsForXTimes(self:GetCaster(), self:GetParent(), self.one_palm_damage, 0.17, 3, 6)
        playSound(self:GetParent(), 0.26, 3)
    end

    if self.interval_count == 4 then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_6, 3)
        PopupManaDrain(self:GetParent(),math.floor(9))
        self:GetParent():EmitSound("neji_64_hit")
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.one_palm_damage,
            damage_type = self:GetAbility():GetAbilityDamageType()
        })
        burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
        damageAfterXSecondsForXTimes(self:GetCaster(), self:GetParent(), self.one_palm_damage, 0.08, 7, 10)
        playSound(self:GetParent(), 0.19, 4)
    end

    if self.interval_count == 5 then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_6, 4)
        PopupManaDrain(self:GetParent(),math.floor(17))
        self:GetParent():EmitSound("neji_64_hit")
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.one_palm_damage,
            damage_type = self:GetAbility():GetAbilityDamageType()
        })
        burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
        damageAfterXSecondsForXTimes(self:GetCaster(), self:GetParent(), self.one_palm_damage, 0.04, 15, 18)
        playSound(self:GetParent(), 0.12, 5)
    end

    if self.interval_count == 6 then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_6, 5)
        PopupManaDrain(self:GetParent(),math.floor(33))
        self:GetParent():EmitSound("neji_64_hit")
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.one_palm_damage,
            damage_type = self:GetAbility():GetAbilityDamageType()
        })
        burnMana(self:GetParent(), 30.0, 1, self:GetCaster()) 
        damageAfterXSecondsForXTimes(self:GetCaster(), self:GetParent(), self.one_palm_damage, 0.02, 31, 34)
        playSound(self:GetParent(), 0.08, 7)
    end

end

function damageAfterXSecondsForXTimes(caster, target, damage, timer, times, popupcount)
    if times > 0 then
        Timers:CreateTimer(timer, function()
            if target:HasModifier("modifier_32_palms_debuff") then
                PopupManaDrain(target,math.floor(popupcount))
                ApplyDamage({
                    victim = target,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL
                })
                burnMana(target, 30.0, 1, caster) 
                damageAfterXSecondsForXTimes(caster, target, damage, timer, times-1, popupcount+1)
            end
        end)
    end
end

function playSound(target, timer, times)
    if times > 0 then
        Timers:CreateTimer(timer, function()
            if target:HasModifier("modifier_32_palms_debuff") then
                target:EmitSound("neji_64_hit")
                playSound(target, timer, times-1)
            end
        end)
    end
end


function burnMana(target, damage_percent, max_mana_percent, caster) 

    if caster:HasModifier("modifier_neji_byakugan_buff") then
        
        local mana = target:GetMana()
        local reduce_mana_amount = target:GetMaxMana() / 100 * max_mana_percent
        local new_mana = mana - reduce_mana_amount
    
        target:SetMana(new_mana)
    
        local damage = reduce_mana_amount / 100 * damage_percent
        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
        })

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