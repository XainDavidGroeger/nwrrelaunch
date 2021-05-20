shikamaru_meditation = shikamaru_meditation or class({})

LinkLuaModifier("modifier_meditation_negative", "heroes/shikamaru/shikamaru_meditation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meditation_positive", "heroes/shikamaru/shikamaru_meditation.lua", LUA_MODIFIER_MOTION_NONE)

function shikamaru_meditation:ProcsMagicStick()
    return true
end

function shikamaru_meditation:OnSpellStart()

	local ability = self
	local caster = self:GetCaster()
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")

	caster:EmitSound("Hero_Dazzle.Weave")

	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local modifier_name_debuff = "modifier_meditation_negative"
    local abilityS = self:GetCaster():FindAbilityByName("special_bonus_shikamaru_3")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	duration = duration + 2
	    end
	end

	for _, unit in pairs(targets) do
		unit:AddNewModifier(caster, ability, modifier_name_debuff, {duration = duration})
	end

	local friends = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local modifier_name = "modifier_meditation_positive"

	for _, unit in pairs(friends) do
		unit:AddNewModifier(caster, ability, modifier_name, {duration = duration})
	end
    
end


modifier_meditation_negative = modifier_meditation_negative or class({})

function modifier_meditation_negative:IsHidden() return false end
function modifier_meditation_negative:IsPurgable() return false end
function modifier_meditation_negative:IsDebuff() return true end

function modifier_meditation_negative:OnCreated(keys)
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_shikamaru_3")

    if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	self.stacks = (self.ability:GetSpecialValueFor("armor") + 2) * -1
	    else
	    	self.stacks = self.ability:GetSpecialValueFor("armor") * -1
	    end
	end

    -- Start interval
    self:StartIntervalThink( 1.0 )
end

function modifier_meditation_negative:OnIntervalThink(keys)
	self.stacks = self.stacks + 1
end

function modifier_meditation_negative:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_meditation_negative:GetModifierPhysicalArmorBonus()
    return  self.stacks
end


modifier_meditation_positive = modifier_meditation_positive or class({})

function modifier_meditation_positive:IsHidden() return false end
function modifier_meditation_positive:IsPurgable() return false end
function modifier_meditation_positive:IsBuff() return true end

function modifier_meditation_positive:OnCreated(keys)
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

    local abilityS = self:GetCaster():FindAbilityByName("special_bonus_shikamaru_3")

    if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	self.stacks = self.ability:GetSpecialValueFor("armor") + 2 
	    else
	    	self.stacks = self.ability:GetSpecialValueFor("armor")
	    end
	end

    -- Start interval
    self:StartIntervalThink( 1.0 )
end

function modifier_meditation_positive:OnIntervalThink(keys)
	self.stacks = self.stacks - 1
end

function modifier_meditation_positive:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_meditation_positive:GetModifierPhysicalArmorBonus()
    return  self.stacks
end