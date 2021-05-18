zabuza_demon_of_the_hidden_mist = zabuza_demon_of_the_hidden_mist or class({})

LinkLuaModifier("modifier_demon_mark", "scripts/vscripts/heroes/zabuza/zabuza_demon_of_the_hidden_mist.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demon_unkillable", "scripts/vscripts/heroes/zabuza/zabuza_demon_of_the_hidden_mist.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demon_of_the_hidden_mist_slow", "scripts/vscripts/heroes/zabuza/zabuza_demon_of_the_hidden_mist.lua", LUA_MODIFIER_MOTION_NONE)

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
    self.caster = caster
	local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	
	self:PlaySound()
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(false, target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(self) then return end
	
	--self.incrDuration = 0
	
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

function zabuza_demon_of_the_hidden_mist:IncreaseDuration(target)
    if self.caster:FindModifierByName("modifier_demon_unkillable") ~= nil then
	    local modifierCaster = self.caster:FindModifierByName("modifier_demon_unkillable")
	    local modifierTarget = target:FindModifierByName("modifier_demon_mark")
		
		modifierCaster:SetDuration(modifierCaster:GetRemainingTime() + 1, true)
		modifierTarget:SetDuration(modifierTarget:GetRemainingTime() + 1, true)
	end
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


modifier_demon_of_the_hidden_mist_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_demon_of_the_hidden_mist_slow:IsHidden()
	return false
end

function modifier_demon_of_the_hidden_mist_slow:IsDebuff()
	return true
end

function modifier_demon_of_the_hidden_mist_slow:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_demon_of_the_hidden_mist_slow:OnCreated( kv )
	-- references
	self.caster = self:GetCaster()
	self.slow_percent = self:GetAbility():GetSpecialValueFor( "ms_slow_start" )
end

function modifier_demon_of_the_hidden_mist_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_demon_of_the_hidden_mist_slow:GetModifierMoveSpeedBonus_Percentage()
	return (-1) * self.slow_percent
end




modifier_demon_mark = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_demon_mark:IsHidden()
	return false
end

function modifier_demon_mark:IsDebuff()
	return true
end

function modifier_demon_mark:IsStunDebuff()
	return false
end

function modifier_demon_mark:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_demon_mark:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_demon_mark:OnCreated( kv )
    self.slow_dur = self:GetAbility():GetSpecialValueFor("ms_slow_dur")
end

function modifier_demon_mark:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_demon_mark:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_demon_mark:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_demon_mark:OnTakeDamage( params )
	if not IsServer() then return end
	
	local attacker = params.attacker
	local ability = self:GetAbility()
	local target = self:GetParent()
	
	if attacker:IsRealHero() and attacker:GetUnitName() == "npc_dota_hero_zabuza" then
		ability:IncreaseDuration(target)
		target:AddNewModifier(
                    attacker, -- player source
                    ability, -- ability source
                    "modifier_demon_of_the_hidden_mist_slow", -- modifier name
                    { duration = self.slow_dur } -- kv
                )
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_demon_mark:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_demon_mark:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf"
end

function modifier_demon_mark:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


modifier_demon_unkillable = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_demon_unkillable:IsHidden()
	return false
end

function modifier_demon_unkillable:IsDebuff()
	return false
end

function modifier_demon_unkillable:IsBuff()
	return true
end

function modifier_demon_unkillable:IsPurgable()
	return true
end

function modifier_demon_unkillable:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_demon_unkillable:OnCreated( kv )
end

function modifier_demon_unkillable:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_demon_unkillable:OnRemoved()
end

function modifier_demon_unkillable:OnDestroy()
end


function modifier_demon_unkillable:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}

	return funcs
end

function modifier_demon_unkillable:GetMinHealth()
	return 1
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_demon_unkillable:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_demon_unkillable:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


