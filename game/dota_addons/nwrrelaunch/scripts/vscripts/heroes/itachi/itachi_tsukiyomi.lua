itachi_tsukiyomi = itachi_tsukiyomi or class({})

LinkLuaModifier("modifier_itachi_slow", "scripts/vscripts/heroes/itachi/modifiers/modifier_itachi_slow.lua", LUA_MODIFIER_MOTION_NONE)

function itachi_tsukiyomi:Precache(context)
	PrecacheResource("soundfile",  "soundevents/game_sounds_heroes/game_sounds_luna.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/heroes/itachi/itachi_tsukyomi_cast_talking.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/itachi_tsukyomi_cast.vsndevts", context)

	PrecacheResource("particle",   "particles/units/heroes/hero_mirana/mirana_moonlight_recipient.vpcf", context)
end

function itachi_tsukiyomi:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function itachi_tsukiyomi:GetCastRange(location, target)
	return self:GetSpecialValueFor("range")
end

function itachi_tsukiyomi:CanBeReflected(bool, target)
	if bool == true then
        if target:TriggerSpellReflect(self) then return end
	else
	    --[[ simulate the cancellation of the ability if it is not reflected ]]
	    ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
		EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
	end
end

function itachi_tsukiyomi:ProcsMagicStick()
	return true
end

function itachi_tsukiyomi:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local slow_duration = self:GetSpecialValueFor("slow_duration")
	local damage = self:GetSpecialValueFor("damage")
	
	EmitSoundOn("itachi_tsukyomi_cast_talking", caster)
	EmitSoundOn("Hero_Luna.Eclipse.Cast", target)
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(true, target) --change to "true" when the ability becomes lua
		
        return
    end
	
	--[[ if the target has Linken's Sphere, cancels the use of the ability ]]
	if target:TriggerSpellAbsorb(self) then return end
	
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_itachi_3")
	local abilityS2 = self:GetCaster():FindAbilityByName("special_bonus_itachi_1")
	
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	duration = duration + 1.5
	    end
	end
	
	if abilityS2 ~= nil then
	    if abilityS2:IsTrained() then
	    	slow_duration = slow_duration + 2.5
	    end
	end
	
	self:PlayEffect(target)
	
	target:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_stunned", -- modifier name
                { duration = duration } -- kv
            )
			
	target:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_itachi_slow", -- modifier name
                { duration = slow_duration } -- kv
            )
			
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end

function itachi_tsukiyomi:PlayEffect(target)
	local tsukiyomi_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(tsukiyomi_particle, 0, target:GetAbsOrigin())
	
	Timers:CreateTimer(2.5, function ()
	    ParticleManager:DestroyParticle(tsukiyomi_particle, true)
		ParticleManager:ReleaseParticleIndex(tsukiyomi_particle)
	end)
end