
LinkLuaModifier("modifier_kankuro_sanshouuo_buff", "heroes/kankuro/summon_sanshouuo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kankuro_sanshouuo_buff_aura", "heroes/kankuro/summon_sanshouuo", LUA_MODIFIER_MOTION_NONE)

kankuro_summon_sanshouuo = class({})

function kankuro_summon_sanshouuo:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT 
end

function kankuro_summon_sanshouuo:ProcsMagicStick()
    return true
end

function kankuro_summon_sanshouuo:OnSpellStart()
	local caster = self:GetCaster()
	local target_point = caster:GetCursorPosition()

	local duration = self:GetSpecialValueFor("puppet_duration")
	local puppet_total_health = self:GetSpecialValueFor("puppet_health")

	local kugusta_ability = caster:FindAbilityByName("kankuro_kugusta_no_jutsu")
    if kugusta_ability ~= nil then
	    if kugusta_ability:GetLevel() > 0 then
        	puppet_total_health = puppet_total_health + kugusta_ability:GetSpecialValueFor("extra_hp")
	    	local abilityspecial = keys.caster:FindAbilityByName("special_bonus_kankuro_6")
			if abilityspecial ~= nil then
	    	    if abilityspecial:IsTrained() then
	    	    	puppet_total_health = puppet_total_health + 350
	    	    end
			end
	    end
	end

	local sanshouuo  = CreateUnitByName("npc_sanshouuo", target_point, true, caster, caster, caster:GetTeamNumber())
	sanshouuo:AddNewModifier(caster, nil, "modifier_phased", { duration = (duration+0.5) } )
	
	sanshouuo:SetBaseMaxHealth(puppet_total_health)
	sanshouuo:ModifyHealth(puppet_total_health, nil, false, 0)

	sanshouuo:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

	sanshouuo:AddNewModifier(caster, self, "modifier_kankuro_sanshouuo_buff", {duration = duration})
	sanshouuo:AddNewModifier(sanshouuo, self, "modifier_kill", {duration = duration})
end

-- Aura Modifier
modifier_kankuro_sanshouuo_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_kankuro_sanshouuo_buff:IsHidden()
	return false
end

function modifier_kankuro_sanshouuo_buff:IsDebuff()
	return false
end

function modifier_kankuro_sanshouuo_buff:IsStunDebuff()
	return false
end

function modifier_kankuro_sanshouuo_buff:IsPurgable()
	return false
end

function modifier_kankuro_sanshouuo_buff:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
	self.aura_vfx = ParticleManager:CreateParticle("particles/units/heroes/kankuro/kankuro_summon_sanshouuo_aura.vpcf", 
												   PATTACH_ABSORIGIN_FOLLOW, 
												   self:GetParent())
	ParticleManager:SetParticleControl(self.aura_vfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.aura_vfx, 1, Vector(self.aura_radius, self.aura_radius, self.aura_radius))
end

function modifier_kankuro_sanshouuo_buff:OnRefresh( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
	if self.aura_vfx ~= nil then
		ParticleManager:SetParticleControl(self.aura_vfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.aura_vfx, 1, Vector(self.aura_radius, 1, 1))
	end
end

function modifier_kankuro_sanshouuo_buff:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING]	= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		-- [MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_kankuro_sanshouuo_buff:OnRemoved()
	ParticleManager:DestroyParticle(self.aura_vfx, false)
	ParticleManager:ReleaseParticleIndex(self.aura_vfx)
end

function modifier_kankuro_sanshouuo_buff:GetAuraRadius()
	return self.aura_radius
end

function modifier_kankuro_sanshouuo_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_kankuro_sanshouuo_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_kankuro_sanshouuo_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE 
end

function modifier_kankuro_sanshouuo_buff:IsAura()
	return true
end

function modifier_kankuro_sanshouuo_buff:GetModifierAura()
	return "modifier_kankuro_sanshouuo_buff_aura"
end

-- Modifier that is applied by aura
modifier_kankuro_sanshouuo_buff_aura = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_kankuro_sanshouuo_buff_aura:IsHidden()
	return false
end

function modifier_kankuro_sanshouuo_buff_aura:IsDebuff()
	return false
end

function modifier_kankuro_sanshouuo_buff_aura:IsStunDebuff()
	return false
end

function modifier_kankuro_sanshouuo_buff_aura:IsPurgable()
	return false
end


function modifier_kankuro_sanshouuo_buff_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}
end

function modifier_kankuro_sanshouuo_buff_aura:GetAbsoluteNoDamageMagical(attack_event)
	local sanshouuo = self:GetAuraOwner()
	local sanshouuo_current_health = sanshouuo:GetHealth()

	if attack_event.damage_type ~= DAMAGE_TYPE_MAGICAL then return end

	if attack_event.damage > sanshouuo_current_health then
		local damage_to_take = attack_event.damage + sanshouuo_current_health
		local damage_table = {
			victim = target,
			attacker = attack_event.attacker,
			damage = damage_to_take,
			damage_type = attack_event.damage_type,
			damage_flags = attack_event.damage_flags + DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = attack_event.inflictor,
		}
		ApplyDamage(damage_table)
		sanshouu:ForceKill(false)
		return 0
	else
		sanshouuo:ModifyHealth(sanshouuo_current_health - attack_event.damage, nil, false, 0)
	end

	self.hit_vfx = ParticleManager:CreateParticle("particles/units/heroes/kankuro/kankuro_summon_sanshouuo_aura_hit.vpcf", 
								   PATTACH_ABSORIGIN_FOLLOW, self:GetAbility():GetCaster())
	ParticleManager:SetParticleControl(self.hit_vfx, 0, attack_event.target:GetOrigin())
	ParticleManager:SetParticleControl(self.hit_vfx, 1, sanshouuo:GetOrigin())

	return 1
end

function modifier_kankuro_sanshouuo_buff_aura:GetAbsoluteNoDamagePhysical(attack_event)
	local sanshouuo = self:GetAuraOwner()
	local sanshouuo_current_health = sanshouuo:GetHealth()

	if attack_event.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end

	if attack_event.damage > sanshouuo_current_health then
		local damage_to_take = attack_event.damage + sanshouuo_current_health
		local damage_table = {
			victim = target,
			attacker = attack_event.attacker,
			damage = damage_to_take,
			damage_type = attack_event.damage_type,
			damage_flags = attack_event.damage_flags + DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = attack_event.inflictor,
		}
		ApplyDamage(damage_table)
		sanshouuo:ForceKill(false)
		return 0
	else
		sanshouuo:ModifyHealth(sanshouuo_current_health - attack_event.damage, nil, false, 0)
	end

	self.hit_vfx = ParticleManager:CreateParticle("particles/units/heroes/kankuro/kankuro_summon_sanshouuo_aura_hit.vpcf", 
												  PATTACH_ABSORIGIN_FOLLOW, self:GetAbility():GetCaster())
	ParticleManager:SetParticleControl(self.hit_vfx, 0, attack_event.target:GetOrigin())
	ParticleManager:SetParticleControl(self.hit_vfx, 1, sanshouuo:GetOrigin())

	return 1

end

function modifier_kankuro_sanshouuo_buff_aura:GetAbsoluteNoDamagePure(attack_event)
	local sanshouuo = self:GetAuraOwner()
	local sanshouuo_current_health = sanshouuo:GetHealth()

	if attack_event.damage_type ~= DAMAGE_TYPE_PURE then return end

	if attack_event.damage > sanshouuo_current_health then
		local damage_to_take = attack_event.damage + sanshouuo_current_health
		local damage_table = {
			victim = target,
			attacker = attack_event.attacker,
			damage = damage_to_take,
			damage_type = attack_event.damage_type,
			damage_flags = attack_event.damage_flags + DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = attack_event.inflictor,
		}
		ApplyDamage(damage_table)
		sanshouuo:ForceKill(false)
		return 0
	else
		sanshouuo:ModifyHealth(sanshouuo_current_health - attack_event.damage, nil, false, 0)
	end

	self.hit_vfx = ParticleManager:CreateParticle("particles/units/heroes/kankuro/kankuro_summon_sanshouuo_aura_hit.vpcf", 
												  PATTACH_ABSORIGIN_FOLLOW, self:GetAbility():GetCaster())
	ParticleManager:SetParticleControl(self.hit_vfx, 0, attack_event.target:GetOrigin())
	ParticleManager:SetParticleControl(self.hit_vfx, 1, sanshouuo:GetOrigin())

	return 1
end