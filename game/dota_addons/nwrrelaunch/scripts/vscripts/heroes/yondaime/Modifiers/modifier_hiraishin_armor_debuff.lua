modifier_hiraishin_armor_debuff = class({})

--------------------------------------------------------------------------------

function modifier_hiraishin_armor_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

function modifier_hiraishin_armor_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end
--[[ ============================================================================================================
    Author: Dave
    Date: October 24, 2015
    -- adds a modifier which slows the target on x percent(depening on the 'neji_byakugan' level)
================================================================================================================= ]]
function modifier_hiraishin_armor_debuff:GetModifierPhysicalArmorBonus(keys)

    local minus_armor = self:GetAbility():GetSpecialValueFor( "armor_reduction")

    if self:GetAbility():GetCaster():FindAbilityByName("special_bonus_yondaime_4"):GetLevel() > 0 then
		minus_armor = minus_armor - 3
	end

    return 	minus_armor
end