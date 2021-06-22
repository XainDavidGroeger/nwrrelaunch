modifier_shikamaru_stun = class({})

--------------------------------------------------------------------------------

function modifier_shikamaru_stun:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_shikamaru_stun:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_shikamaru_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_shikamaru_stun:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function modifier_shikamaru_stun:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_shikamaru_stun:RemoveOnDeath()
	return false
end