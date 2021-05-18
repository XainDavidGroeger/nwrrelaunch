modifier_demon_mark = class({})

LinkLuaModifier("modifier_zabuza_slow", "scripts/vscripts/heroes/zabuza/modifiers/modifier_zabuza_slow.lua", LUA_MODIFIER_MOTION_NONE)

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
                    "modifier_zabuza_slow", -- modifier name
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