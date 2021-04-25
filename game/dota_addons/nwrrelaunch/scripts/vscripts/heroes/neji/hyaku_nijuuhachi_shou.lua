--[[Author: LearningDave
	Date: October, 9th 2015
	Reveals the target if its invisible]]
function hyaku_nijuuhachi_shou_invis_check( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	keys.ability.target = target
	if target:IsInvisible() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {})
	end
end

function createParticle( keys )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/neji/ulti/bagum_projected.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControl(particle, 0, keys.caster:GetAbsOrigin()) -- Origin
	keys.ability.ultiParticle = particle
end

function removeParticle( keys )
	ParticleManager:DestroyParticle( keys.ability.ultiParticle, true )
end

function silenceTarget( keys )
	local abilityS = keys.caster:FindAbilityByName("special_bonus_neji_4")
	if abilityS:IsTrained() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.ability.target, "modifier_hyaku_nijuuhachi_shou_special_silence", {duration = 5})
	end
end

function removeModifiers( keys )
	keys.caster:RemoveModifierByName("modifier_hyaku_nijuuhachi_shou_caster")
	keys.ability.target:RemoveModifierByName("modifier_hyaku_nijuuhachi_shou")
	keys.ability.target:RemoveModifierByName("modifier_fiend_grip_invis_datadriven")
end