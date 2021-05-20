
---------------------------------------------------------------------
-------------------------	Blink Strike	-------------------------
---------------------------------------------------------------------
zabuza_stealth = zabuza_stealth or class({})
function zabuza_stealth:IsHiddenWhenStolen() return false end
function zabuza_stealth:IsRefreshable() return true end
function zabuza_stealth:IsStealable() return true end
function zabuza_stealth:IsNetherWardStealable() return false end

function zabuza_stealth:GetAbilityTextureName()
	return "zabuza_stealth"
end
-------------------------------------------

function zabuza_stealth:CastFilterResultTarget(hTarget)
	if hTarget ~= self:GetCaster() then
		return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
	else
		return UF_FAIL_CUSTOM
	end
end

function zabuza_stealth:GetCustomCastErrorTarget(hTarget)
	if hTarget == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	end
end

function zabuza_stealth:GetCastRange(location , target)
	local extracastrange = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_zabuza_1")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	extracastrange =  300
	    end
	end

	return self.BaseClass.GetCastRange(self,location,target) + extracastrange
end

function zabuza_stealth:ProcsMagicStick()
	return true
end

function zabuza_stealth:OnSpellStart()
	if IsServer() then
		self.hCaster = self:GetCaster()
		self.hTarget = self:GetCursorTarget()
		local hTarget = self.hTarget
		local last_position = self:GetCaster():GetAbsOrigin()
		local direction = (self.hTarget:GetAbsOrigin() - last_position):Normalized()
		local target_loc = hTarget:GetAbsOrigin()
		self.hCaster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 3.5)
		self.hCaster:SetAbsOrigin(self.hCaster:GetAbsOrigin())
		self.hCaster:PerformAttack(hTarget, true, true, true, false, false, false, true)
		local location = target_loc - (hTarget:GetForwardVector()*100)
		self.hCaster:SetForwardVector(direction)
		self.hCaster:SetAbsOrigin(location)
	end
end