shikamaru_kage_kubishibari = shikamaru_kage_kubishibari or class({})

LinkLuaModifier("modifier_kubishibari", "heroes/shikamaru/shikamaru_kage_kubishibari.lua", LUA_MODIFIER_MOTION_NONE)


function shikamaru_kage_kubishibari:GetChannelTime()
	local caster = self:GetCaster()

    local channel_time = self.BaseClass.GetChannelTime(self)

    if self:GetCaster():FindAbilityByName("special_bonus_shikamaru_4"):GetLevel() > 0 then
		channel_time =  channel_time + 2
	end

	return channel_time 
end

function shikamaru_kage_kubishibari:OnSpellStart()

    self.target = self:GetCursorTarget()

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local ability = self

    local duration = self:GetSpecialValueFor("duration")

    if self:GetCaster():FindAbilityByName("special_bonus_shikamaru_4"):GetLevel() > 0 then
		duration =  duration + 2
	end

    target:AddNewModifier(caster, ability, "modifier_kubishibari", {duration = duration})
    
end

function shikamaru_kage_kubishibari:OnChannelFinish(bInterrupted)
    if self.target and not self.target:IsNull() and self.target:FindModifierByName("modifier_kubishibari") then
		self.target:FindModifierByName("modifier_kubishibari"):Destroy()
	end
end


--modifier
modifier_kubishibari = modifier_kubishibari or class({})

function modifier_kubishibari:IsHidden() return false end
function modifier_kubishibari:IsPurgable() return false end
function modifier_kubishibari:IsDebuff() return true end

function modifier_kubishibari:OnCreated(keys)
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

    -- todo attach effect

    -- Start interval
    self:StartIntervalThink( 0.1 )
end



function modifier_kubishibari:CheckState()
    local state = {
		[MODIFIER_STATE_STUNNED] = true
	}
	return state
end


function modifier_kubishibari:OnIntervalThink()

    local caster = self:GetCaster()
    local target = self:GetParent()
	local ability = self:GetAbility()
	local parent = self:GetParent()
 
    local damage = ability:GetSpecialValueFor( "damage_per_tick")

    if self:GetCaster():FindAbilityByName("special_bonus_shikamaru_1"):GetLevel() > 0 then
		damage = damage + 5
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	ApplyDamage( damageTable )

end
