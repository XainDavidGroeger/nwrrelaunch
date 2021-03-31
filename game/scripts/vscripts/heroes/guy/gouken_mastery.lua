--[[
	Author: LearningDave
	Date: October, 28th 2015
	Does apply and popup damage to the target (doubled damage of the current attack damage)
]]
function ApplyDoubleDamage( keys )
	if not keys.target:IsBuilding() then

		local abilityS2 = keys.caster:FindAbilityByName("special_bonus_guy_3")
		if abilityS2:IsTrained() == false and keys.special == 1 then
			return false
		end
		if abilityS2:IsTrained() and keys.special == 0 then
			return false
		end

		local target = keys.target
		local caster = keys.caster
		local ability = keys.ability
		local abilityDamageType = ability:GetAbilityDamageType()
		local damage = caster:GetBaseDamageMin() + ((caster:GetBaseDamageMax() - caster:GetBaseDamageMin())  / 2 )

		PopupDamage(target, damage * 2)
		local damageTable = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = abilityDamageType
			}
		ApplyDamage( damageTable )
	end
end