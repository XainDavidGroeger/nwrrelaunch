--[[Author LearningDave
	Date october, 9th 2015
	Swaps caster model
]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	local ability = keys.ability
	local projectile_model = keys.projectile_model

	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	caster.caster_attack = caster:GetAttackCapability()

	-- Sets the new model and projectile

	caster:SetOriginalModel(model)
	caster:SetModelScale(0.65)

	keys.ability.dome = ParticleManager:CreateParticle("particles/units/heroes/kisame/water_dome2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(keys.ability.dome, 0, caster:GetAbsOrigin()) -- Origin
	
	keys.ability.dome_sharks = ParticleManager:CreateParticle("particles/units/heroes/kisame/water_dome2_sharks.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(keys.ability.dome_sharks, 1, caster:GetAbsOrigin()) -- Origin
end
--[[Author LearningDave
	Date october, 9th 2015
	Reverts back to the original model
]]
function ModelSwapEnd( keys )
	local caster = keys.caster
	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:SetModelScale(1.2)
	ParticleManager:DestroyParticle( keys.ability.dome, true )
	ParticleManager:DestroyParticle(keys.ability.dome_sharks, true)
end
--[[
	Author LearningDave
	Date october, 9th 2015.
	Reduces the mana of the caster and swap the model if zero mana is reached
]]
function ManaCost( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local manacost_percentage = keys.ability:GetLevelSpecialValueFor("mana_cost_per_second_percentage", keys.ability:GetLevel() - 1 )
	local max_mana = caster:GetMaxMana()
	local mana_reduce = max_mana / 100 * manacost_percentage / 10
	local current_mana = caster:GetMana()
	local new_mana = current_mana - mana_reduce
	local modifer = keys.modifierRemove
	if (current_mana - mana_reduce) <= 0 then
		caster:SetMana(1)
		caster:SetModel(caster.caster_model)
		caster:SetOriginalModel(caster.caster_model)
		caster:RemoveModifierByName("modifier_kisame_metamorphosis")
		ability:ToggleAbility()
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
	else
		caster:SetMana(new_mana)
	end
end
--[[Author: LearningDave
	Date: 04.11.2015
	Creates a dummy at the target location that acts as the Water prison
]]
function createWaterPrisonDome( keys )
	-- Variables
	keys.caster:Interrupt()
	local caster = keys.caster
	local ability = keys.ability
	local target_point = caster:GetAbsOrigin()

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})
	keys.ability.domeDummy = dummy
	print(dummy:GetAbsOrigin())
	print(caster:GetAbsOrigin())
end
--[[Author: LearningDave
	Date: 04.11.2015
	Makes sure the dummy with the attached water prison effect follows the caster
]]
function domeFollowHero( keys )
	if keys.ability.domeDummy ~= nil and not keys.ability.domeDummy:IsNull() then
		if keys.ability.domeDummy:GetAbsOrigin() ~= keys.caster:GetAbsOrigin() then
			FindClearSpaceForUnit(keys.ability.domeDummy, keys.caster:GetAbsOrigin(), true)
		end
	end
end


function applySlowModifer( keys )

	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetLevelSpecialValueFor("radius",ability:GetLevel() - 1)
	local targets = FindUnitsInRadius(
		keys.target:GetTeamNumber(), 
		keys.caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local ability4 = caster:FindAbilityByName("special_bonus_kisame_4")
	if ability4 ~= nil then
	    if ability4:IsTrained() then
	    	for _, unit in pairs(targets) do
	    		ability:ApplyDataDrivenModifier(keys.caster, unit, "modifer_water_prison_slow_special",{duration = 0.2})
	    	end
	    else
	    	for _, unit in pairs(targets) do
	    		ability:ApplyDataDrivenModifier(keys.caster, unit, "modifer_water_prison_slow",{duration = 0.2})
	    	end
	    end
	end
end

function emitCastSound( keys )
	keys.caster:EmitSound("kisame_water_prison_cast")
end

function AddToggleSound( keys )
	keys.togglesound = keys.caster:EmitSound("kisame_water_prison_toggle")
end

function RemoveToggleSound( keys )
	keys.caster:StopSound("kisame_water_prison_toggle")
end

LinkLuaModifier("modifier_kisame_water_prision_caster", "heroes/kisame/water_prison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kisame_water_prision_aura", "heroes/kisame/water_prison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kisame_water_prision_debuff_stacks", "heroes/kisame/water_prison", LUA_MODIFIER_MOTION_NONE)


kisame_water_prison = class({})

function kisame_water_prison:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_kisame_water_prision_caster", {})

	if not IsServer() then return end
	-- check sister ability
	local ability = caster:FindAbilityByName("kisame_water_prison_deactivate")
	if not ability then
		ability = caster:AddAbility( "kisame_water_prison_deactivate" )
		ability:SetStolen( true )
	end

	-- check ability level
	ability:SetLevel( self:GetLevel() )

	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)

	--Sound
	caster:EmitSound("kisame_water_prison_cast")
	caster:EmitSound("kisame_water_prison_toggle") --Loop
end


kisame_water_prison_deactivate = class({})

function kisame_water_prison_deactivate:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_kisame_water_prision_caster")
end


modifier_kisame_water_prision_caster = class({})

function modifier_kisame_water_prision_caster:IsHidden() return false end
function modifier_kisame_water_prision_caster:IsDebuff() return false end
function modifier_kisame_water_prision_caster:IsPurgable() return false end
function modifier_kisame_water_prision_caster:RemoveOnDeath() return true end

function modifier_kisame_water_prision_caster:OnCreated()
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
	self.move_speed_bonus_perc = self:GetAbility():GetSpecialValueFor("ms_buff")
	self.hp_regen_perc = self:GetAbility():GetSpecialValueFor("hp_reg_per_second_percentage")

	if not IsServer() then return end

	self.caster:SetModelScale(0.65)

	self.dome_vfx = ParticleManager:CreateParticle(
		"particles/units/heroes/kisame/water_dome2.vpcf", 
		PATTACH_ABSORIGIN_FOLLOW, 
		self.caster
	)
	ParticleManager:SetParticleControl(self.dome_vfx, 0, self.caster:GetAbsOrigin()) -- Origin
	
	self.dome_sharks_vfx = ParticleManager:CreateParticle(
		"particles/units/heroes/kisame/water_dome2_sharks.vpcf", 
		PATTACH_ABSORIGIN_FOLLOW, 
		self.caster
	)
	ParticleManager:SetParticleControl(self.dome_sharks_vfx, 0, self.caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControl(self.dome_sharks_vfx, 3, Vector(self.aura_radius,0,0)) -- Origin
end

function modifier_kisame_water_prision_caster:OnDestroy()

	local caster = self:GetAbility():GetCaster()
	local ability = caster:FindAbilityByName( "kisame_water_prison" )

	--Remove loop sound

	if not IsServer() then return end
	caster:SwapAbilities(
		"kisame_water_prison",
		"kisame_water_prison_deactivate",
		true,
		false
	)

	caster:StopSound("kisame_water_prison_toggle")

	ParticleManager:DestroyParticle(self.dome_vfx, true)
	ParticleManager:DestroyParticle(self.dome_sharks_vfx, true)
	ParticleManager:ReleaseParticleIndex(self.dome_vfx)
	ParticleManager:ReleaseParticleIndex(self.dome_sharks_vfx)

	caster:SetModelScale(1.1)

end

function modifier_kisame_water_prision_caster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end

function modifier_kisame_water_prision_caster:GetModifierModelChange()
	return "models/kisame_shark/kisame_shark.vmdl"
end

-- function modifier_kisame_water_prision_caster:GetModifierModelScale()
-- 	return 6.5
-- end

function modifier_kisame_water_prision_caster:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_bonus_perc
end

function modifier_kisame_water_prision_caster:GetModifierHealthRegenPercentage()
	return self.hp_regen_perc
end

function modifier_kisame_water_prision_caster:IsAura()
	return true
end

function modifier_kisame_water_prision_caster:IsAuraActiveOnDeath()
	return false
end

function modifier_kisame_water_prision_caster:GetModifierAura()
	return "modifier_kisame_water_prision_aura"
end

function modifier_kisame_water_prision_caster:GetAuraDuration()
	return 0.5
end

function modifier_kisame_water_prision_caster:GetAuraRadius()
	return self.aura_radius
end

function modifier_kisame_water_prision_caster:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_kisame_water_prision_caster:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_kisame_water_prision_caster:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


modifier_kisame_water_prision_aura = class({})

function modifier_kisame_water_prision_aura:OnCreated()
	self.think_counter = 0
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")
	self.stack_duration = self.ability:GetSpecialValueFor("stacks_duration")
	self.interval = self.ability:GetSpecialValueFor("tick_interval")
	self.damage_per_tick = self.interval * self.ability:GetSpecialValueFor("damage_per_second")
	self.bonus_damage_per_tick_per_stack = self.interval * self.ability:GetSpecialValueFor("damage_per_stack")
	self.parent_stacks = 0
	self.move_speed_debuff = self.ability:GetSpecialValueFor("ms_slow_percentage") + self.caster:FindTalentValue("special_bonus_kisame_4")
	self.move_speed_debuff_per_stack = 5
	self.move_speed_debuff_per_stack = self.ability:GetSpecialValueFor("ms_slow_percentage_per_stack")
	print(self.move_speed_debuff_per_stack)
	self.damage_table = {
		attacker = self.caster,
		damage = self.damage_per_tick,
		victim = self.parent,
		damage_type = self.ability:GetAbilityDamageType(),
		damage_flags = 0,
		ability = self.ability,
	}
	self:StartIntervalThink(self.interval)
end

function modifier_kisame_water_prision_aura:OnIntervalThink()
	self.think_counter = self.think_counter + self.interval
	local stack_modifier = self.parent:FindModifierByName("modifier_kisame_water_prision_debuff_stacks")
	if stack_modifier then
		self.parent_stacks = stack_modifier:GetStackCount()
	end
	self:ForceRefresh()

	--add stacks
	if self.think_counter >= 1 then
		self.think_counter = 0
		if stack_modifier then
			local stack_counter = stack_modifier:GetStackCount()
			print(stack_counter)
			print(self.max_stacks)
			if stack_counter < self.max_stacks then
				stack_modifier:IncrementStackCount()
				print("increased")
			end
			stack_modifier:SetDuration(self.stack_duration, true)
		else
			local new_stack_modifier = self.parent:AddNewModifier(
				self.caster, 
				self.ability, 
				"modifier_kisame_water_prision_debuff_stacks", 
				{duration = self.stack_duration})
			new_stack_modifier:SetStackCount(1)
		end
	end

	--damage
	self.damage_table.damage = self.damage_per_tick + self.parent_stacks * self.bonus_damage_per_tick_per_stack
	ApplyDamage(self.damage_table)
end

function modifier_kisame_water_prision_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_kisame_water_prision_aura:GetModifierMoveSpeedBonus_Percentage()
	return -1 * ( self.move_speed_debuff + (self.move_speed_debuff_per_stack * self.parent_stacks) )
end


modifier_kisame_water_prision_debuff_stacks = class({})

function modifier_kisame_water_prision_debuff_stacks:IsHidden() return false end
function modifier_kisame_water_prision_debuff_stacks:IsDebuff() return true end

