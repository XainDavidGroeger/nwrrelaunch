madara_wood_release = class({})
LinkLuaModifier("modifier_madara_burning_tree_dot", "heroes/madara/wood_release", LUA_MODIFIER_MOTION_NONE)

function madara_wood_release:GetCooldown(level)
	if self:GetCaster():HasTalent("special_bonus_madara_3") then
		return self.BaseClass.GetCooldown( self, level ) - self:GetSpecialValueFor("cd_reduc")
	else
		return self.BaseClass.GetCooldown( self, level )
	end
end

function madara_wood_release:ProcsMagicStick()
    return true
end

function madara_wood_release:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("madara_trees")

	return true
end

function madara_wood_release:OnSpellStart()
	local radius = self:GetSpecialValueFor("radius")
	local caster = self:GetCaster()

	local tree_duration = self:GetSpecialValueFor("tree_duration")
	
	local ability2 = caster:FindAbilityByName("special_bonus_madara_2")
	if ability2 ~= nil then
		if ability2:IsTrained() then
			tree_duration = tree_duration + 1.5
		end
	end 

	local tree_vision = self:GetSpecialValueFor("tree_vision")
	local target_point = self:GetCursorPosition()
	local tree_count = 10
	local scope = math.pi * radius
	local posX = 0
	local posY = 0
	local r = radius / 2
	for i = 1,tree_count do
			posX = target_point.x + r * math.cos((math.pi*2/tree_count) * i)
			posY = target_point.y + r * math.sin((math.pi*2/tree_count) * i)
			CreateTempTree( Vector( posX, posY, 0.0 ), tree_duration )
			local nearbyUnits = FindUnitsInRadius(caster:GetTeamNumber(), Vector( posX, posY, 0.0 ), nil, 50, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
			if nearbyUnits then
				for _,unit in pairs(nearbyUnits) do
					FindClearSpaceForUnit(unit, target_point, true)
				end
			end
			--local dummy = CreateUnitByName( "npc_tree", Vector(posX, posY, 0.0), false, keys.caster, nil, keys.caster:GetTeamNumber() )
	end
	AddFOWViewer( caster:GetTeamNumber(), target_point, tree_vision, tree_duration, false )

end

function madara_wood_release:BurnTree(tree)
	local stopCheck = false
	local tree_burn_duration = self:GetSpecialValueFor("tree_burn_duration")
	local tree_vision = self:GetSpecialValueFor("tree_vision")
	local origin = tree:GetAbsOrigin()
	local caster = self:GetCaster()
	local ability = self
	xcoord = origin.x
	ycoord = origin.y
	--local dummy = CreateUnitByName( "npc_burning_tree", Vector(xcoord, ycoord, 0.0), false, keys.caster, nil, keys.caster:GetTeamNumber() )
	--dummy:GetAbilityByIndex(0):SetLevel(wood_ability_level)
	GridNav:DestroyTreesAroundPoint(origin, 40, true)
	local treesSecond = GridNav:GetAllTreesAroundPoint(origin, 50, false) 
	
	local particle = ParticleManager:CreateParticle("particles/units/heroes/madara/burning_tree.vpcf", PATTACH_CUSTOMORIGIN, nil) 
	ParticleManager:SetParticleControl(particle , 0, origin)
	 
	Timers:CreateTimer( function()
		local targetEntities = FindUnitsInRadius(caster:GetTeam(), 
												 origin, 
												 nil, 
												 tree_vision, 
												 DOTA_UNIT_TARGET_TEAM_ENEMY, 
												 DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
												 0, 
												 FIND_ANY_ORDER, 
												 false)
		if targetEntities then
			for _,oneTarget in pairs(targetEntities) do
				local modifier = oneTarget:FindModifierByName("burning_tree_dot")
				if modifier == nil then
					-- self:ApplyDataDrivenModifier(self:GetCaster(), oneTarget, "burning_tree_dot", {Duration = tree_burn_duration})
					oneTarget:AddNewModifier(caster,
											ability, 
											"modifier_madara_burning_tree_dot", 
											{Duration = tree_burn_duration})
					local particle = ParticleManager:CreateParticle("particles/dire_fx/fire_barracks_glow_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, nil) 
					ParticleManager:SetParticleControl(particle , 0, oneTarget:GetAbsOrigin())
				end
			end
		end

		if not stopCheck then
			return 0.25
		else
			return nil
		end
			
	end)

	Timers:CreateTimer( tree_burn_duration, function()
			stopCheck = true
			ParticleManager:DestroyParticle(particle, true)
		return nil
	end)
end


modifier_madara_burning_tree_dot = class({})


function modifier_madara_burning_tree_dot:OnCreated()
	if not IsServer() then return end

	self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
	self.damage_per_tick = self:GetAbility():GetSpecialValueFor("burn_damage") * self.dot_interval
	self:StartIntervalThink(self.dot_interval)

	self.dot_damage_table = {
		attacker = self:GetAbility():GetCaster(),
		victim = self:GetParent(),
		ability = self:GetAbility(),
		damage = self.damage_per_tick,
		damage_type = self:GetAbility():GetAbilityDamageType(),
	}

end

function modifier_madara_burning_tree_dot:OnIntervalThink()
	ApplyDamage(self.dot_damage_table)
end