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
	-- references
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_reduction" )
end

function modifier_demon_unkillable:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_demon_unkillable:OnRemoved()

-- Variables
	local ability = self:GetAbility()
	
	local minimumHealth = 1
	
	if (self.target:GetHealth() - self.damageTaken) < minimumHealth then
		self.target:Kill(ability, self.target.lastAttacker)
	else
		self.target:SetHealth(self.target:GetHealth() - self.damageTaken)
	end
	
	self.damageTaken = 0
	self.target.lastAttackerResort = nil
	self.target.lastAttacker = nil
end

function modifier_demon_unkillable:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_demon_unkillable:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_demon_unkillable:GetModifierIncomingDamage_Percentage()
	return self.reduction
end

function modifier_demon_unkillable:GetMinHealth()
	return 1
end

function modifier_demon_unkillable:OnTakeDamage( params )
	if not IsServer() then return end
	
	self.target = params.unit
	local attacker = params.attacker
	local caster = self:GetParent()	
	
	if attacker:IsRealHero() and attacker ~= self:GetParent() then
	    self.damageTaken = params.damage
	    --caster:SetHealth(caster:GetHealth() + self.damageTaken) -- why?
		self.target.lastAttacker = attacker
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_demon_unkillable:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_demon_unkillable:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end