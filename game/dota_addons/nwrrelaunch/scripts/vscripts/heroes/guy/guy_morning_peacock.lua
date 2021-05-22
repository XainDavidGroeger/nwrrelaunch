guy_morning_peacock = guy_morning_peacock or class({})
LinkLuaModifier( "modifier_guy_morning_peacock_buff", "scripts/vscripts/heroes/guy/guy_morning_peacock.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guy_morning_peacock_cd_reset", "scripts/vscripts/heroes/guy/guy_morning_peacock.lua", LUA_MODIFIER_MOTION_NONE )

function guy_morning_peacock:Precache(context)
	PrecacheResource("soundfile",  "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/heroes/guy/guy_gouken_talking.vsndevts", context)
end

function guy_morning_peacock:GetAbilityTextureName()
	return "guy_morning_peacock"
end

function guy_morning_peacock:GetIntrinsicModifierName()
	return "modifier_guy_morning_peacock_cd_reset"
end

function guy_morning_peacock:ProcsMagicStick()
    return true
end

function guy_morning_peacock:OnSpellStart()
	-- apply modifier
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_guy_morning_peacock_buff", {})
end

modifier_guy_morning_peacock_buff = modifier_guy_morning_peacock_buff or class({})

function modifier_guy_morning_peacock_buff:IsHidden() return false end
function modifier_guy_morning_peacock_buff:IsBuff() return true end

function modifier_guy_morning_peacock_buff:OnCreated()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self:SetStackCount(0)
	
	self.damage_timer = Timers:CreateTimer(0.0, function ()
		if self.caster:HasModifier("modifier_guy_morning_peacock_buff") then
			self.damage = (-1) * (self.caster:GetAverageTrueAttackDamage(nil) / 100 * 25)
		end
		return 1
	end)
end

function modifier_guy_morning_peacock_buff:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_guy_morning_peacock_buff:OnRemoved()
	Timers:RemoveTimer(self.damage_timer)
end

function modifier_guy_morning_peacock_buff:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_guy_morning_peacock_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
end

function modifier_guy_morning_peacock_buff:GetModifierBaseAttack_BonusDamage()
	return self.damage
end

function modifier_guy_morning_peacock_buff:GetModifierBaseAttackTimeConstant()
	return 0.1
end

modifier_guy_morning_peacock_cd_reset = modifier_guy_morning_peacock_cd_reset or class({})

function modifier_guy_morning_peacock_cd_reset:IsHidden() return false end
function modifier_guy_morning_peacock_cd_reset:IsBuff() return true end

function modifier_guy_morning_peacock_cd_reset:OnCreated()
	self.ability = self:GetAbility()
end

function modifier_guy_morning_peacock_cd_reset:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_guy_morning_peacock_cd_reset:OnAttackLanded(params) -- health handling
	if not IsServer() then return end

	if params.attacker == self:GetCaster() then
		
		if params.target:IsBuilding() then
			return nil
		end

		if self:GetCaster():HasModifier("modifier_guy_morning_peacock_buff") then

			if self:GetStackCount() == 0 then
				self.ability:EndCooldown()
				self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()))
			end

			self:SetStackCount(self:GetStackCount() + 1)

			params.target:AddNewModifier(self:GetCaster(), self.ability, "modifier_stunned", {duration = self.ability:GetSpecialValueFor("stun")})

			if self:GetStackCount() == 4 then
				self:SetStackCount(0)
				self:GetCaster():RemoveModifierByName("modifier_guy_morning_peacock_buff")
			end
		else
			if not self.ability:IsCooldownReady() then
				local new_cd = self.ability:GetCooldownTimeRemaining() - 1.0
				self.ability:EndCooldown()
				self.ability:StartCooldown(new_cd)
			end
		end
		
	end
end



