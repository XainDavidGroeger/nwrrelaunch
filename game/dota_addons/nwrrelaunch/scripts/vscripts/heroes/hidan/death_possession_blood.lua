--[[Author LearningDave
	Date november, 2nd 2015
	Swaps caster model
]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	local projectile_model = keys.projectile_model

	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	caster.caster_attack = caster:GetAttackCapability()

	-- Sets the new model and projectile

	-- TODO readd 2nd model of hidan, not working atm
	--	caster:SetOriginalModel(model)

end
--[[Author LearningDave
	Date october, 9th 2015
	Reverts back to the original model
]]
function ModelSwapEnd( keys )
	local caster = keys.caster

	--caster:SetModel(caster.caster_model)
	--caster:SetOriginalModel(caster.caster_model)
end
--[[Author: LearningDave
	Date: 22.10.2015
	Creates a dummy at the target location that acts as the Jashin Circle
	]]
function createJashinCirlce( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.caster:GetAbsOrigin()

	-- Special Variables
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})


	-- Timer to remove the dummy
	Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end
--[[Author LearningDave
	Date november, 2th 2015
	Sets the target for this ability
]]
function setTarget( keys )
	if keys.target:IsRealHero() then
		if keys.ability.bloodTarget then
			keys.ability.bloodTarget:RemoveModifierByName("modifier_hidan_ulti_debuff")
		end
		keys.ability.bloodTarget = keys.target
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_hidan_ulti_debuff",{duration = 20})
		
		keys.ability.targetTime = Time()
		local targetTime = Time()

		Timers:CreateTimer(20, function() 
			if keys.ability.targetTime == targetTime then 
				keys.target:RemoveModifierByName("modifier_hidan_ulti_debuff")
				keys.ability.bloodTarget = nil 
				end 
		end)
	end
end
--[[Author LearningDave
	Date november, 2th 2015
	Initiates the variables for this ability
]]
function initiateTarget( keys )
	keys.ability.bloodTarget = nil
end
--[[Author LearningDave
	Date november, 2th 2015
	Applies damage to the marked target
]]
function apply_damage( keys )
	if keys.ability.bloodTarget ~= nil then 
		local target = keys.ability.bloodTarget
		local abilityDamageType = keys.ability:GetAbilityDamageType()
		local damage = keys.Damage
		local displayDamage = tonumber(string.format("%." ..  0 .. "f", damage))
		PopupDamage(target, displayDamage)

		local damageTable = {
			victim = target,
			attacker = keys.caster,
			damage = damage,
			damage_type = abilityDamageType
		}
		ApplyDamage( damageTable )
	end
end
--[[Author LearningDave
	Date november, 2th 2015
	Applies the modifier_hidan_in_circle modifier to hidan if he is inside the jashin circle
]]
function apply_circle_modifier( keys )
	if keys.target == keys.caster then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_hidan_in_circle", {Duration = 1})
	end
end
--[[Author LearningDave
	Date november, 2th 2015
	Adds Self Pain to Hidan'S abilities
]]
function addSelfPainAbility( keys )
	selfPain = keys.caster:FindAbilityByName("hidan_self_pain")
    selfPain:SetLevel(keys.ability:GetLevel())
end
--[[Author LearningDave
	Date november, 2th 2015
	Removes Self Pain from Hidan'S abilities
]]
function removeSelfPain( keys )
	selfPain = keys.caster:FindAbilityByName("hidan_self_pain")
    selfPain:SetLevel(0)
end

function addDebuff( keys )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hidan/ritual_debuff_core.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:SetParticleControlEnt(particle, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_origin", keys.target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_origin", keys.target:GetAbsOrigin(), true)
	keys.target.debuffHidan = particle
end

function removeDebuff( keys )

	ParticleManager:DestroyParticle(keys.target.debuffHidan, true)

end

hidan_death_possession_blood = class({})
LinkLuaModifier("modifier_death_possession_blood_caster_on_attack", "heroes/hidan/death_possession_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_death_possession_blood_target", "heroes/hidan/death_possession_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_death_possession_blood_dummy_aura", "heroes/hidan/death_possession_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_death_possession_blood_dummy_aura_inside_ring", "heroes/hidan/death_possession_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_death_possession_blood_caster_buff", "heroes/hidan/death_possession_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_death_possession_blood_caster_status", "heroes/hidan/death_possession_blood", LUA_MODIFIER_MOTION_NONE)


function hidan_death_possession_blood:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	--Learn Self Pain ability
	caster:FindAbilityByName("hidan_self_pain"):SetLevel(self:GetLevel())

	-- Dummy
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, self, "modifier_phased", {})
	dummy:AddNewModifier(caster, self, "modifier_death_possession_blood_dummy_aura", {duration = duration})
	dummy:AddNewModifier(caster, self, "modifier_kill", {duration = duration})

	-- Apply buuf to caster
	caster:AddNewModifier(caster, self, "modifier_death_possession_blood_caster_buff", {duration = duration})

	-- Sounds
	caster:EmitSound("hidan_ulti_cast_talking")
end

function hidan_death_possession_blood:GetIntrinsicModifierName()
	return "modifier_death_possession_blood_caster_on_attack"
end

modifier_death_possession_blood_caster_on_attack = class({})

function modifier_death_possession_blood_caster_on_attack:IsHidden() return false end
function modifier_death_possession_blood_caster_on_attack:IsPassive() return true end

function modifier_death_possession_blood_caster_on_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_death_possession_blood_caster_on_attack:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.stacks = 0

	if not IsServer() then return end
	self:SetHasCustomTransmitterData( true )

end

function modifier_death_possession_blood_caster_on_attack:AddCustomTransmitterData()
	-- on server
	local data = {
		current_blood_target_name = self.current_blood_target_name
	}

	return data
end

function modifier_death_possession_blood_caster_on_attack:HandleCustomTransmitterData( data )
	-- on client
	self.current_blood_target_name = data.current_blood_target_name
end


function modifier_death_possession_blood_caster_on_attack:OnAttackLanded( attack_event )

	if attack_event.attacker ~= self:GetAbility():GetCaster() then return end

	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local mark_duration = ability:GetSpecialValueFor("mark_duration")


	if ability.current_blood_target ~= nil then
		ability.current_blood_target:RemoveModifierByName("modifier_death_possession_blood_target")
	end

	if attack_event.target:IsHero() and attack_event.fail_type == DOTA_ATTACK_RECORD_FAIL_NO then
		-- Set modifier to the target
		ability.current_blood_target = attack_event.target
		self.current_blood_target_name = attack_event.target:GetUnitName()
		if IsClient() then
			print(ability.current_blood_target_name)
		end
		attack_event.target:AddNewModifier(caster, 
											ability, 
											"modifier_death_possession_blood_target", 
											{duration = mark_duration})

		-- Set status for caster
		local status_modifier = caster:AddNewModifier(caster, 
														ability, 
														"modifier_death_possession_blood_caster_status", 
														{duration = mark_duration})
		-- status_modifier.texture = attack_event.target:GetUnitName()
		-- status_modifier.GetTexture = function () return attack_event.target:GetUnitName() end
		-- print()
		-- print(status_modifiers)
		-- print(status_modifier.GetTexture)
	end

	return nil
	
end


modifier_death_possession_blood_target = class({})

function modifier_death_possession_blood_target:IsBuff()
	return false
end

function modifier_death_possession_blood_target:IsHidden()
	return false
end

function modifier_death_possession_blood_target:IsPurgable()
	return false
end


function modifier_death_possession_blood_target:OnCreated(event)
	if IsServer() then
		self.target_vfx = ParticleManager:CreateParticle("particles/units/heroes/hidan/ritual_debuff_core.vpcf",  
														PATTACH_CUSTOMORIGIN_FOLLOW, 
														self:GetAbility():GetCaster())
		ParticleManager:SetParticleControlEnt(self.target_vfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.target_vfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetOrigin(), true)
	end
end

function modifier_death_possession_blood_target:OnRefresh()
	if IsServer() then
		if self.target_vfx ~= nil then
			ParticleManager:SetParticleControlEnt(self.target_vfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.target_vfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetOrigin(), true)	
		end
	end
end

function modifier_death_possession_blood_target:OnRemoved()
	self:GetAbility().current_blood_target = nil
	local caster = self:GetAbility():GetCaster()
	if IsServer() and caster:HasModifier("modifier_death_possession_blood_caster_status") then
		caster:RemoveModifierByName("modifier_death_possession_blood_caster_status")

		ParticleManager:DestroyParticle(self.target_vfx, false)
		ParticleManager:ReleaseParticleIndex(self.target_vfx)
	end
end


modifier_death_possession_blood_caster_status = class({})

function modifier_death_possession_blood_caster_status:IsBuff()
	return true
end

function modifier_death_possession_blood_caster_status:IsHidden()
	return false
end

function modifier_death_possession_blood_caster_status:IsPurgable()
	return false
end

function modifier_death_possession_blood_caster_status:OnCreated()

end

function modifier_death_possession_blood_caster_status:GetTexture()

	return self.texture
end


modifier_death_possession_blood_dummy_aura = class({})

function modifier_death_possession_blood_dummy_aura:IsBuff()
	return true
end

function modifier_death_possession_blood_dummy_aura:IsHidden()
	return false
end

function modifier_death_possession_blood_dummy_aura:IsPurgable()
	return false
end

function modifier_death_possession_blood_dummy_aura:IsAura()
	return true
end

function modifier_death_possession_blood_dummy_aura:CheckState()
	return {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
			[MODIFIER_STATE_NO_TEAM_SELECT] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_OUT_OF_GAME] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end

function modifier_death_possession_blood_dummy_aura:OnCreated( kv )
	local caster = self:GetAbility():GetCaster()
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.ring_vfx = ParticleManager:CreateParticle("particles/units/heroes/hidan/hidan_blood_possession_ring.vpcf",
	PATTACH_POINT , caster)
	ParticleManager:SetParticleControl(self.ring_vfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.ring_vfx, 1, Vector(self.aura_radius, 1, 1))

end

function modifier_death_possession_blood_dummy_aura:OnRemoved()
	ParticleManager:DestroyParticle(self.ring_vfx, false)
	ParticleManager:ReleaseParticleIndex(self.ring_vfx)

end

function modifier_death_possession_blood_dummy_aura:GetModifierAura()
	return "modifier_death_possession_blood_dummy_aura_inside_ring"
end

function modifier_death_possession_blood_dummy_aura:GetAuraRadius()
	return self.aura_radius
end

function modifier_death_possession_blood_dummy_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_death_possession_blood_dummy_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_death_possession_blood_dummy_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE 
end


modifier_death_possession_blood_dummy_aura_inside_ring = class({})

function modifier_death_possession_blood_dummy_aura:IsBuff()
	return true
end

function modifier_death_possession_blood_dummy_aura:IsHidden()
	return false
end

function modifier_death_possession_blood_dummy_aura:IsPurgable()
	return false
end

function modifier_death_possession_blood_dummy_aura:IsAura()
	return true
end


modifier_death_possession_blood_caster_buff = class({})

function modifier_death_possession_blood_caster_buff:IsBuff()
	return true
end

function modifier_death_possession_blood_caster_buff:IsHidden()
	return false
end

function modifier_death_possession_blood_caster_buff:IsPurgable()
	return false
end

function modifier_death_possession_blood_caster_buff:GetEffectName()
	return "particles/units/heroes/hidan/ritual_owner.vpcf"
end

function modifier_death_possession_blood_caster_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_death_possession_blood_caster_buff:GetStatusEffectName()
	return "particles/units/heroes/hidan/ritual_self_status_effect.vpcf"
end

function modifier_death_possession_blood_caster_buff:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA 
end

function modifier_death_possession_blood_caster_buff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE 
	}
end

function modifier_death_possession_blood_caster_buff:OnTakeDamage(attack_event)

	if attack_event.unit ~= self:GetAbility():GetCaster() then return end

		local ability = self:GetAbility()
		local caster = ability:GetCaster()
	

	if ability.current_blood_target ~= nil then

		local damage_multiplier = ability:GetSpecialValueFor("returned_damage_outside_percentage") / 100
		-- local damage_multiplier_inside_ring = ability:GetSpecialValueFor("returned_damage_inside_percentage") / 100
		if caster:HasModifier("modifier_death_possession_blood_dummy_aura_inside_ring") then 
			damage_multiplier = ability:GetSpecialValueFor("returned_damage_inside_percentage") / 100
		end

		local damage_table = {
			victim = ability.current_blood_target,
			attacker = caster,
			damage = attack_event.damage * damage_multiplier,
			damage_type = attack_event.damage_type,
			damage_flags = attack_event.damage_flags,
			ability = ability,
		}

		ApplyDamage(damage_table)

	end
end

function modifier_death_possession_blood_caster_buff:OnRemoved()
	local caster = self:GetAbility():GetCaster()
	caster:FindAbilityByName("hidan_self_pain"):SetLevel(0)
end