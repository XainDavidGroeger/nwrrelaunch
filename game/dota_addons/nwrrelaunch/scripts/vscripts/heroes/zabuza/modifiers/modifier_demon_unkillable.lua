modifier_demon_unkillable = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_demon_unkillable:IsHidden()
	return false
end

function modifier_demon_unkillable:IsDebuff()
	return false
end

function modifier_demon_unkillable:IsBuff()
	return true
end

function modifier_demon_unkillable:IsPurgable()
	return true
end

function modifier_demon_unkillable:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_demon_unkillable:OnCreated( kv )
end

function modifier_demon_unkillable:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_demon_unkillable:OnRemoved()
end

function modifier_demon_unkillable:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_demon_unkillable:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}

	return funcs
end

function modifier_demon_unkillable:GetMinHealth()
	return 1
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_demon_unkillable:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_demon_unkillable:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end