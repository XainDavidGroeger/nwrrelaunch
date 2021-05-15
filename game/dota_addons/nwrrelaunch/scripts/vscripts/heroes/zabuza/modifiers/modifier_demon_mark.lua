modifier_demon_mark = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_demon_mark:IsHidden()
	return false
end

function modifier_demon_mark:IsDebuff()
	return true
end

function modifier_demon_mark:IsStunDebuff()
	return false
end

function modifier_demon_mark:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_demon_mark:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_demon_mark:OnCreated( kv )
	if IsServer() then
		self.silence = false
	end
end

function modifier_demon_mark:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_demon_mark:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_demon_mark:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_demon_mark:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf"
end

function modifier_demon_mark:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end