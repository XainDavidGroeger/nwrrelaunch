kakashi_bunshin = kakashi_bunshin or class({})

LinkLuaModifier("modifier_kakashi_bunshin_charge", "scripts/vscripts/heroes/kakashi/modifiers/modifier_kakashi_bunshin_charge.lua", LUA_MODIFIER_MOTION_NONE)

function kakashi_bunshin:Precache(context)
	PrecacheResource("soundfile",  "soundevents/heroes/kakashi/kakashi_bunshin_cast.vsndevts", context)
	PrecacheResource("particle",   "particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", context)
	PrecacheResource("particle",   "particles/generic_hero_status/status_invisibility_start.vpcf", context)
	PrecacheResource("particle",   "particles/items_fx/chain_lightning.vpcf", context)
	PrecacheResource("particle",   "particles/units/heroes/hero_razor/razor_ambient_g.vpcf", context)
	PrecacheResource("particle",   "particles/units/heroes/invis/lamp_flame_tintable.vpcf", context)
end

function kakashi_bunshin:GetCooldown(iLevel)
	local cdrecution = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_kakashi_3")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	cdrecution = 3
	    end
	end
	return self.BaseClass.GetCooldown(self, iLevel) - cdrecution
end

function kakashi_bunshin:ProcsMagicStick()
	return true
end

function kakashi_bunshin:OnSpellStart()
    local caster = self:GetCaster()
	local player = caster:GetPlayerID()
    local duration = self:GetSpecialValueFor("illusion_duration")
    local invisible_duration = self:GetSpecialValueFor("duration")
    local invisible_duration_special = self:GetSpecialValueFor("duration_special")
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local run_to_position = caster:GetAbsOrigin() + 500 * caster:GetForwardVector():Normalized() 
	local outgoingDamage = self:GetSpecialValueFor("illusion_outgoing_damage_percent")
	local incomingDamage = self:GetSpecialValueFor("illusion_incoming_damage_percent")
	
	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, false, caster, nil, caster:GetTeamNumber())
	
	if self.bunshin ~= nil then
        self:RemoveBunshin(self.bunshin)
	end
	
	illusion:SetOwner(caster)
	illusion:SetPlayerID(caster:GetPlayerID()-1)
	illusion:SetControllableByPlayer(player, true)
	illusion:SetForwardVector(caster:GetForwardVector())
	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end
	
	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if illusionAbility ~= nil then
				illusionAbility:SetLevel(abilityLevel)
			end
		end
	end
	
	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end
	
	illusion:SetHealth(caster:GetHealth())
	
	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(caster, self, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	illusion:AddNewModifier(caster, self, "modifier_phased", { duration = 0.5 })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()
	GameMode:RemoveWearables(illusion)
	
	Timers:CreateTimer(0.2,
		function()
		    self.bunshin = illusion
	
            illusion:AddNewModifier(caster, self, "modifier_kakashi_bunshin_charge", { duration = duration })
		end
	)
	
	-- apply invis modifier
	local abilityS = caster:FindAbilityByName("special_bonus_kakashi_1")
	if abilityS ~= nil then
	    if abilityS:IsTrained() then
			invisible_duration = invisible_duration_special
		end
	end
	caster:AddNewModifier(caster, self, "modifier_invisible", { duration = invisible_duration })
	
	-- Move to the same direction as the caster
	Timers:CreateTimer(0.05,
		function()
		    if illusion ~= nil then
			    illusion:MoveToPosition(run_to_position)
			end
		end
	)
	
	Timers:CreateTimer(duration - 0.3,
		function()
		    if illusion ~= nil then
			    self:RemoveBunshin(illusion)
			end
		end
	)
end

function kakashi_bunshin:RemoveBunshin(illusion)
    if illusion ~= nil then
        local dummy = CreateUnitByName("npc_dummy_unit", illusion:GetAbsOrigin(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam())
	    local lightningChain = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_WORLDORIGIN, dummy)
	    ParticleManager:SetParticleControl(lightningChain,0,Vector(dummy:GetAbsOrigin().x,dummy:GetAbsOrigin().y,dummy:GetAbsOrigin().z + dummy:GetBoundingMaxs().z ))	
	    dummy:RemoveSelf()
	    EmitSoundOn("clone_pop", illusion)
	    illusion:ForceKill(false)
              
        Timers:CreateTimer(0.1, function()
            illusion:Destroy()
	    	illusion = nil
	    	self.bunshin = nil
        end)
	end
end