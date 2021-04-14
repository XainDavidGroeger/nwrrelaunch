--[[
	Author: LearningDave
	Date: October, 28th 2015
	Does apply and popup damage to the target (doubled damage of the current attack damage)
]]
function ApplyDoubleDamage( keys )
	if not keys.target:IsBuilding() then

		local target = keys.target
		local caster = keys.caster
		local ability = keys.ability
		local abilityDamageType = ability:GetAbilityDamageType()

		local bonus_dmg_percentage = ability:GetLevelSpecialValueFor( "bonus_damage_percentage", ( ability:GetLevel() - 1 ) )

		local abilityS2 = keys.caster:FindAbilityByName("special_bonus_guy_3")
		if abilityS2:IsTrained()then
			bonus_dmg_percentage = bonus_dmg_percentage + 35
		end
		local damage = (caster:GetBaseDamageMin() + ((caster:GetBaseDamageMax() - caster:GetBaseDamageMin())  / 2 )) / 100 * bonus_dmg_percentage
	
		local averagedmg = caster:GetBaseDamageMin() + ((caster:GetBaseDamageMax() - caster:GetBaseDamageMin())  / 2 )

		PopupDamage(target, averagedmg + damage)
		local damageTable = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = abilityDamageType
			}
		ApplyDamage( damageTable )
	end
end