--[[ ============================================================================================================
	Anko's Sojasosai No Jutsu
	Author: Zenicus
	Date: November 19, 2015
	 -- Applies damage based on target's missing HP to target and self
	- Converted from datadriven to lua by EarthSalamander
	- Date: 27.04.2021
================================================================================================================= ]]

LinkLuaModifier("modifier_anko_senei_ta_jashu_poison", "scripts/vscripts/heroes/anko/anko_senei_ta_jashu.lua", LUA_MODIFIER_MOTION_NONE)

anko_sojasosai_no_jutsu = anko_sojasosai_no_jutsu or class({})

function anko_sojasosai_no_jutsu:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/anko/sacrifice_impact.vpcf", context)
	PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context)
	PrecacheResource("soundfile","soundevents/heroes/anko/anko_sacrifice_cast.vsndevts", context)
	PrecacheResource("soundfile","soundevents/heroes/anko/anko_sacrifice_impact.vsndevts", context)

end

function anko_sojasosai_no_jutsu:CanBeReflected(bool, target)
    if bool == true then
        if target:TriggerSpellReflect(self) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function anko_sojasosai_no_jutsu:ProcsMagicStick()
    return true
end

function anko_sojasosai_no_jutsu:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("anko_sacrifice_cast")
	return true
end

function anko_sojasosai_no_jutsu:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage_percent = self:GetSpecialValueFor("damage_percent")
	local target_max_hp = target:GetMaxHealth()
	local final_damage = target_max_hp * damage_percent / 100
	local damageType = self:GetAbilityDamageType()
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(false, target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(self) then return end

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = final_damage,
		damage_type = damageType,
	})

	ApplyDamage({
		victim = caster,
		attacker = caster,
		damage = final_damage,
		damage_type = damageType,
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
	})

	local particle = ParticleManager:CreateParticle("particles/units/heroes/anko/sacrifice_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) 
	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)

	self:GetCaster():EmitSound("anko_sacrifice_impact")
end
