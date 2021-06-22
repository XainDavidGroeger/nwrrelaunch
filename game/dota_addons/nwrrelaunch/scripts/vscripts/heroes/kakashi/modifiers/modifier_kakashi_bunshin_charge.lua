modifier_kakashi_bunshin_charge = class({})

LinkLuaModifier("modifier_kakashi_lighting_charge", "scripts/vscripts/heroes/kakashi/modifiers/modifier_kakashi_lighting_charge.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Classifications
function modifier_kakashi_bunshin_charge:IsHidden()
	return false
end

function modifier_kakashi_bunshin_charge:IsDebuff()
	return false
end

function modifier_kakashi_bunshin_charge:IsBuff()
	return true
end

function modifier_kakashi_bunshin_charge:IsPurgable()
	return true
end

function modifier_kakashi_bunshin_charge:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_kakashi_bunshin_charge:OnCreated( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor("lighting_charge_duration")
end

function modifier_kakashi_bunshin_charge:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_kakashi_bunshin_charge:OnRemoved()
end

function modifier_kakashi_bunshin_charge:OnDestroy()
	local ability = self:GetAbility()
	ability:BunshinDeathParticles(ability.bunshin:GetAbsOrigin())
	ability.bunshin = nil
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_kakashi_bunshin_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_kakashi_bunshin_charge:OnTakeDamage(params)
	if not IsServer() then return end
	local attacker = params.attacker
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	
	if attacker:IsRealHero() and attacker ~= caster then
		-- if not attacker:IsMagicImmune() then
		-- 	attacker:AddNewModifier(caster, ability, "modifier_kakashi_lighting_charge", { duration = self.duration })
		-- end
		ability:BunshinDeathParticles(attacker:GetAbsOrigin())
		EmitSoundOn("clone_pop", ability.bunshin)
		ability.bunshin:ForceKill(false)
          
        -- Timers:CreateTimer(0.1, function()
        --     ability.bunshin:Destroy()
		-- 	ability.bunshin = nil
        -- end)
	end
end