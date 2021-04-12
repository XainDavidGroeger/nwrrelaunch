require('./settings')

-- Set the new speed of the courier
if modifier_courier_speed == nil then
	modifier_courier_speed = class({})
end

-- Returns the attributes and functions that the modifier will have
function modifier_courier_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_MAX
    }

    return funcs
end

-- True/false if this modifier is active on illusions.
function modifier_courier_speed:AllowIllusionDuplicate()
    return true
end

-- Return the types of attributes applied to this modifier (enum value from DOTAModifierAttribute_t)
function modifier_courier_speed:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

-- Return the priority of the modifier, see MODIFIER_PRIORITY_*.
function modifier_courier_speed:GetPriority()
    return MODIFIER_PRIORITY_NORMAL
end

-- Return the name of the buff icon to be shown for this modifier.
function modifier_courier_speed:GetTexture()
    return 'courier_burst'
end

-- True/false if this modifier should be displayed as a debuff.
function modifier_courier_speed:IsDebuff()
    return false
end

-- True/false if this modifier should be displayed on the buff bar.
function modifier_courier_speed:IsHidden()
    return false
end

-- True/false if this modifier can be purged.
function modifier_courier_speed:IsPurgable()
    return false
end

-- True/false if this modifier is considered a stun for purge reasons.
function modifier_courier_speed:IsStunDebuff()
    return false
end

-- 
function modifier_courier_speed:GetModifierMoveSpeedBonus_Percentage()
    return COURIER_SPEED_BONUS
end

--
function modifier_courier_speed:GetModifierMoveSpeed_Limit()
    return 2000
end

--
function modifier_courier_speed:GetModifierMoveSpeed_Max()
    return 2000
end