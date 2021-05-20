--[[
  Author: LearningDave
  Date: November, 2nd 2015
  Applies True damage to the caster. Cant kil the caster(1hp will be set)
  Checks if hidan is in his Jashin Cirle(by modifier), if so the marked target gets 100% damage, else lessS
]]
function self_pain( keys )
	local caster = keys.caster
	local ability = keys.ability

	local damage = ability:GetLevelSpecialValueFor("damage",ability:GetLevel() - 1)

	local abilityS = caster:FindAbilityByName("special_bonus_hidan_2")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
	    	damage = damage + 225
	    end
	end

	local override_damage = false
	local health = caster:GetHealth()
	PopupDamage(caster, damage)
	if (caster:GetHealth() - damage) > 0 then
		caster:SetHealth(caster:GetHealth() - damage)
	else
		caster:SetHealth(1)
		override_damage = true
	end


	-- local abilityDamageType = keys.ability:GetAbilityDamageType()
	-- local ability_index = keys.caster:FindAbilityByName("hidan_death_possession_blood"):GetAbilityIndex()
    -- local death_possession_blood_ability = keys.caster:GetAbilityByIndex(ability_index)
    -- local death_possession_blood_ability_level = keys.caster:GetAbilityByIndex(ability_index):GetLevel()
    -- local returned_damage_outside_percentage = death_possession_blood_ability:GetLevelSpecialValueFor( "returned_damage_outside_percentage", ( death_possession_blood_ability:GetLevel() - 1 ) )

    -- local particle = ParticleManager:CreateParticle("particles/units/heroes/hidan/hidan_passive_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	-- ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) 
	-- ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin()) 

    -- if caster:HasModifier("modifier_hidan_metamorphosis") then 
    -- 	if caster:HasModifier("modifier_hidan_in_circle") then 
    -- 		if death_possession_blood_ability.bloodTarget ~= nil then
    -- 			local damage = damage
    -- 			if override_damage then
    -- 				damage = (-1 * (health - damage))
    -- 			end

    -- 			local displayDamage = tonumber(string.format("%." ..  0 .. "f", damage))
	-- 			PopupDamage(death_possession_blood_ability.bloodTarget, displayDamage)

	-- 			local damageTable = {
	-- 				victim = death_possession_blood_ability.bloodTarget,
	-- 				attacker = keys.caster,
	-- 				damage = damage,
	-- 				damage_type = abilityDamageType
	-- 			}
	-- 			ApplyDamage( damageTable )
    -- 		end
    -- 	else
    -- 		if death_possession_blood_ability.bloodTarget ~= nil then 
    -- 			local damage = damage / 100 * returned_damage_outside_percentage
    -- 			if override_damage then
    -- 				damage = (-1 * (health - damage)) / 100 * returned_damage_outside_percentage
    -- 			end
    -- 			local displayDamage = tonumber(string.format("%." ..  0 .. "f", damage))
	-- 			PopupDamage(death_possession_blood_ability.bloodTarget, displayDamage)
	-- 			local damageTable = {
	-- 				victim = death_possession_blood_ability.bloodTarget,
	-- 				attacker = keys.caster,
	-- 				damage = damage,
	-- 				damage_type = abilityDamageType
	-- 			}
	-- 			ApplyDamage( damageTable )
    -- 		end
    -- 	end
    -- end


end

hidan_self_pain = class({})

function hidan_self_pain:Precache(context)
	PrecacheResource("soundfile",  "soundevents/heroes/hidan/hidan_self_pain_talking.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/hidan_self_pain_cast.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/hidan_self_pain_fire.vsndevts", context)

	PrecacheResource("particle",   "particles/units/heroes/hidan/self_pain.vpcf", context)
end

function hidan_self_pain:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("hidan_self_pain_cast")
	return true
end

function hidan_self_pain:OnSpellStart( event )
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local talent_ability = caster:FindAbilityByName("special_bonus_hidan_2")

	caster:EmitSound("hidan_self_pain_talking")
	caster:EmitSound("hidan_self_pain_fire")
	
	if talent_ability ~= nil then
	    if talent_ability:IsTrained() then
	    	local damage = damage + talent_ability:GetSpecialValueFor("value")
	    end
	end

	local vfx = ParticleManager:CreateParticle("particles/units/heroes/hidan/self_pain.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(vfx, 0, caster:GetAbsOrigin())

	damage_table = {
		attacker = caster,
		victim = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
		ability = self,
	}

	ApplyDamage(damage_table)

end