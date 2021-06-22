--[[
	Author: LearningDave
	Date: october, 5th 2015.
	Cleave Damage based on caster str and reduces enemy damage
]]
function ReleaseAoeDamage( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1
	local aoe = event.ability:GetLevelSpecialValueFor("aoe", ability_level )
	
	if event.target:IsBuilding() then
		return nil
	end

	-- Find Enemy Targets in AOE
	local targetEntities = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

    --If there are targets do something
	if targetEntities then
		--Loop each target / Apply damage to each target and add modfier
		
		EmitSoundOn("raikage_straight_impact", caster)
		
		local strength = caster:GetStrength()

		local str_ratio = event.ability:GetLevelSpecialValueFor("str_ratio_damage", ability_level )

		local ability1 = caster:FindAbilityByName("special_bonus_raikage_1")

		if ability1 ~= nil then
			if ability1:IsTrained() then
				str_ratio = str_ratio + 0.5
			end
		end
		

		local spell_damage = strength * str_ratio
		
		local damage_table = {
			attacker = caster,
			victim = nil,
			ability = ability,
			damage_type = ability:GetAbilityDamageType(),
			damage = spell_damage
		}
	
		for _,target in pairs(targetEntities) do
			damage_table.victim = target
			ApplyDamage(damage_table)

			local ability5 = caster:FindAbilityByName("special_bonus_raikage_5")
			if ability5 ~= nil then
				if ability5:IsTrained() then
					ability:ApplyDataDrivenModifier(caster, target, "modifier_raigyaku_debuff_special",{})
				else
					ability:ApplyDataDrivenModifier(caster, target, "modifier_raigyaku_debuff",{})
				end
			else
				ability:ApplyDataDrivenModifier(caster, target, "modifier_raigyaku_debuff",{})
			end

		end
	end

end

--[[
	Author: LearningDave
	Date: october, 5th 2015.
	Reset Cooldown after attack islanded
]]
function SuiheiResetCooldown( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetCooldown( ability:GetLevel() -1)
	local modifierName = "modifier_raigyaku"
	
	-- Remove cooldown
	caster:RemoveModifierByName( modifierName )
	ability:StartCooldown( cooldown )
	Timers:CreateTimer( cooldown, function()
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
			return nil
		end
	)
end


function attachEffect( keys )

	-- Fire particle
	local fxIndex = ParticleManager:CreateParticle( "particles/econ/items/spirit_breaker/spirit_breaker_thundering_flail/spirit_breaker_thundering_flail.vpcf", PATTACH_CUSTOMORIGIN, keys.caster )
	ParticleManager:SetParticleControlEnt( fxIndex, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_lefthand", keys.target:GetAbsOrigin(), true)
	keys.ability.left = fxIndex
-- Fire particle
	local fxIndex = ParticleManager:CreateParticle( "particles/econ/items/spirit_breaker/spirit_breaker_thundering_flail/spirit_breaker_thundering_flail.vpcf", PATTACH_CUSTOMORIGIN, keys.caster )
	ParticleManager:SetParticleControlEnt( fxIndex, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_righthand", keys.target:GetAbsOrigin(), true)
	keys.ability.right = fxIndex
end


function removeEffect( keys )
	ParticleManager:DestroyParticle( keys.ability.right, true )
	ParticleManager:DestroyParticle( keys.ability.left, true )
end



LinkLuaModifier("modifier_raikage_raigyaku_suihei_on_attack", "heroes/raikage/raigyaku_suihei", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_raikage_raigyaku_suihei_cooldown", "heroes/raikage/raigyaku_suihei", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_raikage_raigyaku_suihei_vfx", "heroes/raikage/raigyaku_suihei", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_raikage_raigyaku_suihei_debuff", "heroes/raikage/raigyaku_suihei", LUA_MODIFIER_MOTION_NONE)

raikage_raigyaku_suihei = class({})

function raikage_raigyaku_suihei:GetIntrinsicModifierName()
	return "modifier_raikage_raigyaku_suihei_on_attack"
end

function raikage_raigyaku_suihei:OnUpgrade()
	local modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
	if modifier then
		modifier:ForceRefresh()
	end
end


modifier_raikage_raigyaku_suihei_on_attack = class({})

function modifier_raikage_raigyaku_suihei_on_attack:IsPurgable() return false end
function modifier_raikage_raigyaku_suihei_on_attack:IsHidden() return true end

function modifier_raikage_raigyaku_suihei_on_attack:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_raikage_raigyaku_suihei_on_attack:OnCreated()
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = ability:GetCaster()

	if caster:FindModifierByName("modifier_raikage_raigyaku_suihei_vfx") == nil then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_raikage_raigyaku_suihei_vfx", {})
	end
end

function modifier_raikage_raigyaku_suihei_on_attack:OnAttackLanded(event)
	if event.attacker ~= self:GetCaster() or
       event.target:IsBuilding() or 
	   event.target:IsMagicImmune() or 
	   not self:GetAbility():IsCooldownReady()
	then return end

	local ability = self:GetAbility()
	local ability_cooldown = ability:GetCooldown(ability:GetLevel())
	ability:StartCooldown(ability_cooldown)


	local caster = self:GetCaster()
	caster:AddNewModifier(caster, ability, "modifier_raikage_raigyaku_suihei_cooldown", {duration = ability_cooldown})
	caster:RemoveModifierByName("modifier_raikage_raigyaku_suihei_vfx")

	local radius = ability:GetSpecialValueFor("aoe")
	local targetEntities = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		FIND_ANY_ORDER,
		false
	)

	local debuff_duration = ability:GetSpecialValueFor("damage_reduction_duration")

	if targetEntities then
		--Loop each target / Apply damage to each target and add modfier
		
		EmitSoundOn("raikage_straight_impact", caster)
		
		local strength = caster:GetStrength()
		local str_ratio = ability:GetSpecialValueFor("str_ratio_damage") + caster:FindTalentValue("special_bonus_raikage_1")		

		local spell_damage = strength * str_ratio
		
		local damage_table = {
			attacker = caster,
			victim = nil,
			ability = ability,
			damage_type = ability:GetAbilityDamageType(),
			damage = spell_damage
		}

		for _,target in pairs(targetEntities) do
			damage_table.victim = target
			ApplyDamage(damage_table)

			target:AddNewModifier(caster, ability, "modifier_raikage_raigyaku_suihei_debuff", {duration=debuff_duration})

		end
	end
	
end

modifier_raikage_raigyaku_suihei_cooldown = class({})

function modifier_raikage_raigyaku_suihei_cooldown:IsPurgable() return false end
function modifier_raikage_raigyaku_suihei_cooldown:IsHidden() return true end

function modifier_raikage_raigyaku_suihei_cooldown:OnDestroy()
	local caster = self:GetAbility():GetCaster()
	if caster:FindModifierByName("modifier_raikage_raigyaku_suihei_vfx") == nil then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_raikage_raigyaku_suihei_vfx", {})
	end
end

modifier_raikage_raigyaku_suihei_vfx = class({})

function modifier_raikage_raigyaku_suihei_vfx:IsPurgable() return false end
function modifier_raikage_raigyaku_suihei_vfx:IsHidden() return true end


function modifier_raikage_raigyaku_suihei_vfx:OnCreated()
	local ability = self:GetAbility()
	local caster = ability:GetCaster()

	-- Fire particle
	local fxIndex = ParticleManager:CreateParticle( "particles/econ/items/spirit_breaker/spirit_breaker_thundering_flail/spirit_breaker_thundering_flail.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControlEnt( fxIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_lefthand", caster:GetAbsOrigin(), true)
	ability.left_arm_vfx = fxIndex
	-- Fire particle
	local fxIndex = ParticleManager:CreateParticle( "particles/econ/items/spirit_breaker/spirit_breaker_thundering_flail/spirit_breaker_thundering_flail.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControlEnt( fxIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_righthand", caster:GetAbsOrigin(), true)
	ability.right_arm_vfx = fxIndex
end

function modifier_raikage_raigyaku_suihei_vfx:OnDestroy()
	local ability = self:GetAbility()
	ParticleManager:DestroyParticle(ability.left_arm_vfx, false)
	ParticleManager:ReleaseParticleIndex(ability.left_arm_vfx)
	ParticleManager:DestroyParticle(ability.right_arm_vfx, false)
	ParticleManager:ReleaseParticleIndex(ability.right_arm_vfx)
end

modifier_raikage_raigyaku_suihei_debuff = class({})

function modifier_raikage_raigyaku_suihei_debuff:IsPurgable() return true end
function modifier_raikage_raigyaku_suihei_debuff:IsHidden() return false end
function modifier_raikage_raigyaku_suihei_debuff:IsDebuff() return true end

function modifier_raikage_raigyaku_suihei_debuff:HasFunction() 
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_raikage_raigyaku_suihei_debuff:OnCreated()
	local ability =  self:GetAbility()
	self.damage_output_reduction = ability:GetSpecialValueFor("damage_reduction") + ability:GetCaster():FindTalentValue("special_bonus_raikage_5")
end

function modifier_raikage_raigyaku_suihei_debuff:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage_output_reduction
end

function modifier_raikage_raigyaku_suihei_debuff:GetEffectName()
	return "particles/units/heroes/hero_razor/razor_ambient_g.vpcf"
end

function modifier_raikage_raigyaku_suihei_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end