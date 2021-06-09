modifier_onoki_stalagmite_armor = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_onoki_stalagmite_armor:IsHidden()
	return false
end

function modifier_onoki_stalagmite_armor:IsBuff()
	return true
end

function modifier_onoki_stalagmite_armor:IsDebuff()
	return false
end

function modifier_onoki_stalagmite_armor:IsStunDebuff()
	return false
end

function modifier_onoki_stalagmite_armor:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_onoki_stalagmite_armor:OnCreated( kv )
	-- references
	self.caster = self:GetCaster()
	local abilityS = self.caster:FindAbilityByName("special_bonus_onoki_3")
	self.armor_bonus = self:GetAbility():GetSpecialValueFor("bonus_armor")
	
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
        	self.armor_bonus = self.armor_bonus + 8
	    end
	end
	
	--if not IsServer() then return end
	
	-- play sound
	--local sound_cast = "Hero_Dark_Seer.Surge"
	--EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_onoki_stalagmite_armor:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_onoki_stalagmite_armor:OnRemoved()
end

function modifier_onoki_stalagmite_armor:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_onoki_stalagmite_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

function modifier_onoki_stalagmite_armor:GetModifierPhysicalArmorBonus()
    return self.armor_bonus
end

function modifier_onoki_stalagmite_armor:OnAttacked(params)
    if IsServer() then

		if params.target == self:GetParent() then
			local parent = self:GetParent()
			local random_per = self:GetAbility():GetSpecialValueFor("damage_chance")
			local damage = self:GetAbility():GetSpecialValueFor("damage")
			local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
			local damage_type = self:GetAbility():GetAbilityDamageType()
		
			if params.attacker:GetTeamNumber() ~= params.target:GetTeamNumber() and params.attacker:IsTower() == false then
				if RollPercentage(random_per) then
					self:PlayEffects(params.attacker)
					params.attacker:AddNewModifier(parent, self, "modifier_stunned", {duration = stun_duration})
					ApplyDamage({ victim = params.attacker, attacker = parent, damage = damage, damage_type = damage_type })
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_onoki_stalagmite_armor:CheckState()
	local state = {	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_onoki_stalagmite_armor:PlayEffects(target)
    local parent = self:GetParent()
    local attackerForward = target:GetForwardVector()
	local attackerRocks_particle = ParticleManager:CreateParticle("particles/units/heroes/onoki/onoki_rocks_attacker.vpcf", PATTACH_ABSORIGIN, parent)
	ParticleManager:SetParticleControl(attackerRocks_particle, 0, parent:GetAbsOrigin())
	ParticleManager:SetParticleControlOrientation(attackerRocks_particle, 0, -attackerForward, parent:GetRightVector(), parent:GetUpVector())
	
	EmitSoundOn("onoki_armor_proc", parent)
end

function modifier_onoki_stalagmite_armor:GetEffectName()
    return "particles/units/heroes/onoki/onoki_rocks_shield.vpcf"
end

function modifier_onoki_stalagmite_armor:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end