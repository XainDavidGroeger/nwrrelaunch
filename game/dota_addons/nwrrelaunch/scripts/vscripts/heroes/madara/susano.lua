
madara_susano = class({})

function madara_susano:ResetToggleOnRespawn()
	return true
end

function madara_susano:OnToggle()
	if self:GetToggleState() then
		self.modifier = self:GetCaster():AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_madara_susano_caster_active",
			{}
		)

		--Play active sound
	else
		if self.modifier then
			self.modifier:Destroy()
			self.modifier = nil
		end

		--Play endsound
	end
end

function madara_susano:OnUpgrade()
	if self.modifier then
		self.modifier:ForceRefresh()
	end
end

modifier_madara_susano_caster_active = class({})
LinkLuaModifier("modifier_madara_susano_caster_active", "heroes/madara/susano.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_madara_susano_caster_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_madara_susano_caster_active:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magic_resistance_percent")
end

function modifier_madara_susano_caster_active:OnCreated( kv )
	if not IsServer() then return end

	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("burn_radius")
	self.tick_interval = ability:GetSpecialValueFor("tick_interval")
	self.damage_per_tick = ability:GetSpecialValueFor("damage") * self.tick_interval
	self.mana_cost_per_tick = ability:GetSpecialValueFor("mana_cost_per_second") * self.tick_interval

	self.parent = self:GetParent()
	self.damageTable = {
		-- victim = target,
		attacker = self.parent,
		damage = self.damage_per_tick,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability,
	}

	self:OnTickDamage()
	self:StartIntervalThink( self.tick_interval )
end

function modifier_madara_susano_caster_active:CheckState()
	local state = {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true, --This is used to fix pathfinding
	}

	return state
end

function modifier_madara_susano_caster_active:OnRefresh( kv )
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("burn_radius")
	self.tick_interval = ability:GetSpecialValueFor("tick_interval")
	self.damage_per_tick = ability:GetSpecialValueFor("damage") * self.tick_interval
	self.mana_cost_per_tick = ability:GetSpecialValueFor("mana_cost_per_second") * self.tick_interval

	self.parent = self:GetParent()
	self.damageTable = {
		-- victim = target,
		attacker = self.parent,
		damage = self.damage_per_tick,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability,
	}
end

function modifier_madara_susano_caster_active:OnRemoved()
end

function modifier_madara_susano_caster_active:OnDestroy()
	if not IsServer() then return end
	--stop sound loop
end

function modifier_madara_susano_caster_active:OnTickDamage()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- apply damage
		if enemy then
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )
		end
		-- play effects
		-- self:PlayEffects( enemy )
	end

	local wood_release_ability =  self.parent:FindAbilityByName("madara_wood_release")
	if wood_release_ability:IsTrained() then

		local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetAbsOrigin(), self.radius, false) 

		for _,tree in pairs(trees) do
			-- apply damage
			if tree then
				wood_release_ability:BurnTree(tree)
			end
			-- play effects
			-- self:PlayEffects( enemy )
		end
	end

	self.parent:SpendMana( self.mana_cost_per_tick, self.ability )
end

function modifier_madara_susano_caster_active:OnIntervalThink()
	if self.mana_cost_per_tick > self.parent:GetMana() then
		-- turn off
		if self.ability:GetToggleState() then
			self.ability:ToggleAbility()
		end
		return
	end

	self:OnTickDamage()
end

-- Graphics & Animations
function modifier_madara_susano_caster_active:GetEffectName()
	return "particles/units/heroes/madara/susano_core.vpcf"
end

function modifier_madara_susano_caster_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end