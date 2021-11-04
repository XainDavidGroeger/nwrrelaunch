require('./settings')

-- Set the new speed of the courier
if modifier_beastmaster == nil then
	modifier_beastmaster = class({})
end

-- Returns the attributes and functions that the modifier will have
function modifier_beastmaster:DeclareFunctions()
    local funcs = {
    }

    return funcs
end

-- True/false if this modifier is active on illusions.
function modifier_beastmaster:AllowIllusionDuplicate()
    return false
end

-- Return the types of attributes applied to this modifier (enum value from DOTAModifierAttribute_t)
function modifier_beastmaster:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

-- Return the priority of the modifier, see MODIFIER_PRIORITY_*.
function modifier_beastmaster:GetPriority()
    return MODIFIER_PRIORITY_NORMAL
end

-- True/false if this modifier should be displayed as a debuff.
function modifier_beastmaster:IsDebuff()
    return true
end

-- True/false if this modifier should be displayed on the buff bar.
function modifier_beastmaster:IsHidden()
    return true
end

-- True/false if this modifier can be purged.
function modifier_beastmaster:IsPurgable()
    return false
end

-- True/false if this modifier is considered a stun for purge reasons.
function modifier_beastmaster:IsStunDebuff()
    return false
end