sasuke_chidori_kirin = sasuke_chidori_kirin or class({})

LinkLuaModifier("modifier_chidori_kirin_mark", "scripts/vscripts/heroes/sasuke/sasuke_chidori_kirin.lua", LUA_MODIFIER_MOTION_NONE)

function sasuke_chidori_kirin:Precache( context )
    PrecacheResource( "soundfile",   "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_kirin_cast.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_kirin_impact.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_kirin_cast_talking.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_kirin_impact_talking.vsndevts", context )

    PrecacheResource( "particle", "particles/units/heroes/sasuke/kirin/storm_core.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/sasuke/kirin/lighting_bolt.vpcf", context )
end

function sasuke_chidori_kirin:GetAbilityTextureName()
	return "sasuke_chidori_kirin"
end

function sasuke_chidori_kirin:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_chidori_kirin:GetCastRange(location, target)
	return self:GetSpecialValueFor("cast_range")
end

function sasuke_chidori_kirin:CanBeReflected(bool, target)
    if bool == true then
        if target:TriggerSpellReflect(self) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function sasuke_chidori_kirin:ProcsMagicStick()
    return true
end

function sasuke_chidori_kirin:OnSpellStart()
    local target = self:GetCursorTarget()
	
	EmitSoundOn("sasuke_kirin_cast_talking", self:GetCaster())
	EmitSoundOn("sasuke_kirin_cast", target)
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(true, target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(self) then return end
	
	target:AddNewModifier(self:GetCaster(), self, "modifier_chidori_kirin_mark", {duration = self:GetSpecialValueFor("duration")})
end

modifier_chidori_kirin_mark = modifier_chidori_kirin_mark or class({})

function modifier_chidori_kirin_mark:IsHidden() return false end
function modifier_chidori_kirin_mark:IsDebuff() return true end

function modifier_chidori_kirin_mark:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	
	return decFuncs
end

function modifier_chidori_kirin_mark:OnCreated()
	self.caster = self:GetCaster()
	self.stored_damage = 0

	-- add prepare effect
	self.storm = ParticleManager:CreateParticle("particles/units/heroes/sasuke/kirin/storm_core.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( self.storm, 0, self:GetParent():GetAbsOrigin() )

end

function modifier_chidori_kirin_mark:OnTakeDamage(keys)
	-- store damage
	if keys.attacker == self.caster then
		self.stored_damage = self.stored_damage + keys.damage
	end
end

function modifier_chidori_kirin_mark:OnDestroy()

	ParticleManager:DestroyParticle(self.storm, true)
	ParticleManager:ReleaseParticleIndex(self.storm)
	
	EmitSoundOn("sasuke_kirin_impact_talking", self:GetCaster())
	EmitSoundOn("sasuke_kirin_impact", self:GetParent())

	local damage = self:GetAbility():GetSpecialValueFor("base_damage")
	if self.stored_damage > 0 then
		damage = damage + (self.stored_damage * ( self:GetAbility():GetSpecialValueFor("lost_health_bonus_damage") / 100 ))	
	end
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(), 
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility()
	})

end


