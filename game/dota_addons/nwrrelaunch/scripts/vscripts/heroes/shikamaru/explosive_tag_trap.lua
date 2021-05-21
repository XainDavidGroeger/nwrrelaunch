LinkLuaModifier("modifier_shikamaru_explosive_tag_trap_pre_activation", "heroes/shikamaru/explosive_tag_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shikamaru_explosive_tag_trap_active", "heroes/shikamaru/explosive_tag_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )

shikamaru_explosive_tag_trap = class({})

function shikamaru_explosive_tag_trap:Precache(context)
    PrecacheResource("model", "models/shikamaru/shikamaru_kunai_bomb.vmdl", context)
end

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
	
	self.sign_vfx = ParticleManager:CreateParticle("particles/units/heroes/shikamaru/shika_ground_sign.vpcf", PATTACH_ABSORIGIN, trap)
    ParticleManager:SetParticleControl(self.sign_vfx, 0, target_point)
	
	local red_pulse_vfx = ParticleManager:CreateParticle("particles/units/heroes/shikamaru/shika_ground_sign_pulses.vpcf", PATTACH_ABSORIGIN, trap)
    ParticleManager:SetParticleControl(red_pulse_vfx, 0, target_point)
	
	Timers:CreateTimer(1.75, function ()
	    self.invisibility_start_vfx = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, trap)
        ParticleManager:SetParticleControl(self.invisibility_start_vfx, 0, trap:GetAbsOrigin())
		ParticleManager:DestroyParticle(red_pulse_vfx, true)
	    ParticleManager:ReleaseParticleIndex(red_pulse_vfx)
	end)

    trap:AddNewModifier(self:GetCaster(), 
                        self, 
                        "modifier_shikamaru_explosive_tag_trap_pre_activation", 
                        {duration = self:GetSpecialValueFor("activation_time")})

    if self.placed_traps ~= nil then
        if #self.placed_traps >= self:GetSpecialValueFor("max_traps") + self:GetCaster():FindTalentValue("special_bonus_shikamaru_max_traps") then
            local trap_to_explode = table.remove(self.placed_traps, 1)
            if trap_to_explode:FindModifierByName("modifier_shikamaru_explosive_tag_trap_active") then
                trap_to_explode:FindModifierByName("modifier_shikamaru_explosive_tag_trap_active"):TriggerExplosion(nil)
            else
                trap_tp_explode:ForceKill(false)
            end
        end
    end

    if self.placed_traps == nil then
        self.placed_traps = {trap}
    else
        table.insert(self.placed_traps, trap)
    end

end

function shikamaru_explosive_tag_trap:CastFilterResultLocation(target_point)

	-- if IsClient() then
	-- 	if self.custom_indicator then
	-- 		-- register cursor position
	-- 		self.custom_indicator:Register( vLoc )
	-- 	end
	-- end

    if IsClient() then return end 

    local possible_mines = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                                            target_point,
                                            nil,
                                            self:GetSpecialValueFor("trigger_radius"),
                                            DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
                                            DOTA_UNIT_TARGET_ALL, 
                                            DOTA_UNIT_TARGET_FLAG_NONE, 
                                            FIND_ANY_ORDER, 
                                            false)
                                    
    print(possible_mines)

    if possible_mines == nil then return UF_SUCCESS end
    for i=1,#possible_mines do
        if possible_mines[i]:GetUnitName() == "npc_shikamaru_trap" then 
            return UF_FAIL_CUSTOM
        end
    end

    return UF_SUCCESS
end

function shikamaru_explosive_tag_trap:GetCustomCastErrorLocation(target_point)
    return "#error_tag_is_too_close"
end

function shikamaru_explosive_tag_trap:CreateCustomIndicator()
	local particle_cast = "particles/ui_mouseactions/wards_area_view.vpcf"
    if placed_traps == nil then return end
    if self.placed_traps_vfx == nil then self.placed_traps_vfx = {} end
    for i=1,#self.placed_traps do
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
    self.trigger = nil
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
                                    FIND_CLOSEST, 
                                    false)


    if #units ~= 0 then
        if self.trigger ~= nil then
            for i=1,#units do
                if self.trigger == units[i] then
                    self:TriggerExplosion(units[i])
                end
            end
        else
            self.trigger = units[1]
        end
    else
        self.trigger = nil
    end

end

function modifier_shikamaru_explosive_tag_trap_active:TriggerExplosion(target)
    local trap_origin = self:GetParent():GetAbsOrigin()
    local ability = self:GetAbility()
    local radius = self.radius

    self:GetParent():ForceKill(false)
	
    local explosion_vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_ABSORIGIN, self:GetAbility():GetCaster())
    ParticleManager:SetParticleControl(explosion_vfx, 0, trap_origin)
    ParticleManager:SetParticleControl(explosion_vfx, 1, Vector(self.radius, 0, 0))
	
	local sign_vfx = ParticleManager:CreateParticle("particles/units/heroes/shikamaru/shika_ground_sign.vpcf", PATTACH_ABSORIGIN, self:GetAbility():GetCaster())
    ParticleManager:SetParticleControl(sign_vfx, 0, trap_origin)
	
    if target == nil then return end
    local trap_table = self:GetAbility().placed_traps
    for i=1,#trap_table do
        if trap_table[i] == self:GetParent() then
            table.remove(trap_table, i)
        end
    end
	
	local particle_shadow_path_rope = "particles/units/heroes/shikamaru/shikamaru_shadow_imitation_status_rope_for_ult.vpcf"
	local particle_shadow_path_rope_fx = ParticleManager:CreateParticle(particle_shadow_path_rope, PATTACH_ABSORIGIN, self:GetAbility():GetCaster())
	ParticleManager:SetParticleControl(particle_shadow_path_rope_fx, 1, trap_origin)
	ParticleManager:SetParticleControl(particle_shadow_path_rope_fx, 3, target:GetAbsOrigin())
	
	local particle_kunai = "particles/units/heroes/shikamaru/shikamaru_explosive_seal.vpcf"
	local particle_kunai_fx = ParticleManager:CreateParticle(particle_kunai, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle_kunai_fx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_kunai_fx, 1, target:GetAbsOrigin())

    target:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("bind_duration")})

    Timers:CreateTimer({endTime = ability:GetSpecialValueFor("bind_duration") - 0.05, --this reduction by 0.05 is necessary because otherwise damage can be done after the player has moved
        callback = function()
		    ParticleManager:DestroyParticle(particle_kunai_fx, true)
	        ParticleManager:ReleaseParticleIndex(particle_kunai_fx)
			ParticleManager:DestroyParticle(particle_shadow_path_rope_fx, true)
	        ParticleManager:ReleaseParticleIndex(particle_shadow_path_rope_fx)
			ParticleManager:DestroyParticle(sign_vfx, true)
	        ParticleManager:ReleaseParticleIndex(sign_vfx)
		
            local units_to_damage = FindUnitsInRadius(ability:GetCaster():GetTeamNumber(),
            target:GetAbsOrigin(),
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
            ParticleManager:SetParticleControl(explosion_vfx, 0, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(explosion_vfx, 1, Vector(radius, 0, 0))
			
			Timers:CreateTimer(3, function ()
	            ParticleManager:DestroyParticle(explosion_vfx, true)
	        	ParticleManager:ReleaseParticleIndex(explosion_vfx)
				ParticleManager:DestroyParticle(explosion_vfx, true)
	        	ParticleManager:ReleaseParticleIndex(explosion_vfx)
				ParticleManager:DestroyParticle(ability.sign_vfx, true)
	        	ParticleManager:ReleaseParticleIndex(ability.sign_vfx)
				ParticleManager:DestroyParticle(ability.invisibility_start_vfx, true)
	        	ParticleManager:ReleaseParticleIndex(ability.invisibility_start_vfx)
	        end)
    end})
end
