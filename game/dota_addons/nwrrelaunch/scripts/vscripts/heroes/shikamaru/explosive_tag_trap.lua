LinkLuaModifier("modifier_shikamaru_explosive_tag_trap_pre_activation", "heroes/shikamaru/explosive_tag_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shikamaru_explosive_tag_trap_active", "heroes/shikamaru/explosive_tag_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )

shikamaru_explosive_tag_trap = class({})

function shikamaru_explosive_tag_trap:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

function shikamaru_explosive_tag_trap:OnSpellStart()
    local target_point = self:GetCursorPosition()

	local trap = CreateUnitByName( "npc_shikamaru_trap", --name
                                    target_point, --location
                                    true, --find clear space
                                    self:GetCaster(), -- npc owner
                                    nil, -- entity owner
                                    self:GetCaster():GetTeamNumber()) --team
    trap:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)

    trap:AddNewModifier(self:GetCaster(), 
                        self, 
                        "modifier_shikamaru_explosive_tag_trap_pre_activation", 
                        {duration = self:GetSpecialValueFor("activation_time")})

    if self.placed_traps ~= nil then
        if #self.placed_traps >= self:GetSpecialValueFor("max_traps") then
            table.remove(self.placed_traps, 1):FindModifierByName("modifier_shikamaru_explosive_tag_trap_active"):TriggerExplosion()
        end
    end

    if self.placed_traps == nil then
        self.placed_traps = {trap}
    else
        table.insert(self.placed_traps, trap)
    end

    self.other_var = 2

    if IsClient() then
        self.client_var = 1
    end

    if IsClient() then
        print(self.client_var)
        print(self.other_var)
    end

end

function shikamaru_explosive_tag_trap:CastFilterResultLocation(target_point)

	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( vLoc )
		end
	end
    

	-- local ability = self
	-- local caster = ability:GetCaster()
	-- local closest_seal = self:GetClosestSeal(target_point)
	-- local range = self:GetSpecialValueFor("radius")

	-- if closest_seal == nil then
	-- 	return UF_FAIL_CUSTOM
	-- end

	-- local direction = (closest_seal:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

	
	-- local target_entities = FindUnitsInLine(caster:GetTeamNumber(),
	-- 									   caster:GetAbsOrigin() - direction*200,
	-- 									   closest_seal:GetAbsOrigin() + direction*200,
	-- 									   nil,
	-- 									   ability:GetSpecialValueFor("search_width"),
	-- 									   DOTA_UNIT_TARGET_TEAM_ENEMY,
	-- 									   DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
	-- 									   DOTA_UNIT_TARGET_FLAG_NONE)

	-- if #target_entities == 0 then
	-- 	return UF_SUCCESS
	-- end

	-- if (closest_seal:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < self:GetCastRange(target_point ,nil) then
	-- 	return UF_SUCCESS
	-- end
	
	-- return UF_FAIL_CUSTOM

end

function shikamaru_explosive_tag_trap:CreateCustomIndicator()
	local particle_cast = "particles/ui_mouseactions/wards_area_view.vpcf"
    -- print(self.placed_traps)
    if placed_traps == nil then return end
    if self.placed_traps_vfx == nil then self.placed_traps_vfx = {} end
    for i=1,#self.placed_traps do
        -- print(i)
        local vfx = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(vfx, 0, self.placed_traps[i]:GetAbsOrigin())
        ParticleManager:SetParticleControl(vfx, 1, Vector(self:GetSpecialValueFor("trigger_radius"),0,0))
        ParticleManager:SetParticleControl(vfx, 15, Vector(183, 25, 25)) --Color
        ParticleManager:SetParticleControl(vfx, 16, Vector(1, 1, 1))
	    table.insert(self.placed_traps_vfx, vfx)
    end
end

function shikamaru_explosive_tag_trap:DestroyCustomIndicator()
    if self.placed_traps_vfx == nil then return end
    for i=1, #self.placed_traps_vfx do
        ParticleManager:DestroyParticle( self.placed_traps_vfx[i], false )
        ParticleManager:ReleaseParticleIndex( self.placed_traps_vfx[i] )
    end
end


modifier_shikamaru_explosive_tag_trap_pre_activation = class({})

function modifier_shikamaru_explosive_tag_trap_pre_activation:OnCreated()
end

function modifier_shikamaru_explosive_tag_trap_pre_activation:OnRemoved()
    if not IsServer() then return end -- this i s definetely correct
    self:GetParent():AddNewModifier(self:GetAbility():GetCaster(), 
                                    self:GetAbility(), 
                                    "modifier_shikamaru_explosive_tag_trap_active", 
                                    {})
end

modifier_shikamaru_explosive_tag_trap_active = class({})

-- Modifier Effects
function modifier_shikamaru_explosive_tag_trap_active:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}

	return funcs
end

function modifier_shikamaru_explosive_tag_trap_active:GetModifierInvisibilityLevel()
	return 2
end

-- Status Effects
function modifier_shikamaru_explosive_tag_trap_active:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
	}

	return state
end

function modifier_shikamaru_explosive_tag_trap_active:OnCreated()
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor('trigger_delay'))
    self.trigger = false
end

function modifier_shikamaru_explosive_tag_trap_active:OnRemoved()

end

function modifier_shikamaru_explosive_tag_trap_active:OnIntervalThink()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("trigger_radius")
    local units = FindUnitsInRadius(self:GetAbility():GetCaster():GetTeamNumber(),
                                    self:GetParent():GetAbsOrigin(),
                                    nil,
                                    self.radius,
                                    DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                    DOTA_UNIT_TARGET_HERO, 
                                    DOTA_UNIT_TARGET_FLAG_NONE, 
                                    FIND_ANY_ORDER, 
                                    false)

    if #units ~= 0 then
        if self.trigger then
            self:TriggerExplosion(units)
        else
            self.trigger = true
        end
    else
        self.trigger = false    
    end
end

function modifier_shikamaru_explosive_tag_trap_active:TriggerExplosion(units)
    if units == nil then return end
    local trap_table = self:GetAbility().placed_traps
    for i=1,#trap_table do
        if trap_table[i] == self:GetParent() then
            table.remove(trap_table, i)
        end
    end
    local trap_origin = self:GetParent():GetAbsOrigin()
    local ability = self:GetAbility()
    local radius = self.radius
    self:GetParent():ForceKill(false)

    local explosion_vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_ABSORIGIN, self:GetAbility():GetCaster())
    ParticleManager:SetParticleControl(explosion_vfx, 0, trap_origin)
    ParticleManager:SetParticleControl(explosion_vfx, 1, Vector(self.radius, 0, 0))

    for i=1,#units do 
        units[i]:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("bind_duration")})
    end

    Timers:CreateTimer({endTime = ability:GetSpecialValueFor("bind_duration"),
        callback = function()
            local units_to_damage = FindUnitsInRadius(ability:GetCaster():GetTeamNumber(),
            trap_origin,
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO, 
            DOTA_UNIT_TARGET_FLAG_NONE, 
            FIND_ANY_ORDER, 
            false)

            local damage_table = {
                attacker = ability:GetCaster(),
				damage = ability:GetAbilityDamage(),
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
            }

            for i=1,#units_to_damage do 
                damage_table.victim = units_to_damage[i]
                ApplyDamage(damage_table)
            end

            local explosion_vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_ABSORIGIN, ability:GetCaster())
            ParticleManager:SetParticleControl(explosion_vfx, 0, trap_origin)
            ParticleManager:SetParticleControl(explosion_vfx, 1, Vector(radius, 0, 0))
        end})
end
