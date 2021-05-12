shikamaru_kage_kubishibari = shikamaru_kage_kubishibari or class({})

LinkLuaModifier("modifier_kubishibari", "heroes/shikamaru/shikamaru_kage_kubishibari.lua", LUA_MODIFIER_MOTION_NONE)


function shikamaru_kage_kubishibari:GetChannelTime()
	local caster = self:GetCaster()

    local channel_time = self.BaseClass.GetChannelTime(self)
    
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_shikamaru_4")
	if abilityS ~= nil then
        if abilityS:GetLevel() > 0 then
	    	channel_time =  channel_time + 2
	    end
	end

	return channel_time 
end

function shikamaru_kage_kubishibari:CanBeReflected(bool, target)
    if bool == true then
        if target:TriggerSpellReflect(self) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function shikamaru_kage_kubishibari:OnSpellStart()

    self.target = self:GetCursorTarget()

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local ability = self
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(false, target)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(self) then return end

    local duration = self:GetSpecialValueFor("duration")

    local abilityS = self:GetCaster():FindAbilityByName("special_bonus_shikamaru_4")
	if abilityS ~= nil then
        if abilityS:GetLevel() > 0 then
	    	duration =  duration + 2
	    end
	end

	caster:EmitSound("shikamaru_hold_cast")

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
    
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_shikamaru_1")
	if abilityS ~= nil then
        if abilityS:GetLevel() > 0 then
	    	damage = damage + 5
	    end
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	ApplyDamage( damageTable )

end
