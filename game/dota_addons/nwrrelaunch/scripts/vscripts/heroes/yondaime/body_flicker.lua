yondaime_body_flicker = class({})

function yondaime_body_flicker:Precache( context )
    PrecacheResource( "particle",  "particles/units/heroes/yondaime/blink_core_alt.vpcf", context )
    PrecacheResource( "particle",  "particles/units/heroes/yondaime/blink_end_core.vpcf", context )

    PrecacheResource( "soundfile",  "soundevents/heroes/yondaime/minato_flicker_start.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/heroes/yondaime/minato_flicker_end.vsndevts", context )
    PrecacheResource( "soundfile",  "soundevents/heroes/yondaime/minato_flicker_cast_real.vsndevts", context )
end

function yondaime_body_flicker:GetCooldown(iLevel)
	local cdreduction = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_yondaime_5")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	cdreduction = 4
	    end
	end
	return self.BaseClass.GetCooldown(self, iLevel) - cdreduction
end

function yondaime_body_flicker:GetCastRange(location, target)
	if self:GetCaster():HasTalent("special_bonus_yondaime_body_flicker_global") then
		return 9999999
	else
		return 1300
	end
end

function yondaime_body_flicker:OnAbilityPhaseStart( keys )
	self:GetCaster():EmitSound("minato_flicker_start")
	return true
end

function yondaime_body_flicker:ProcsMagicStick()
    return true
end

function yondaime_body_flicker:OnSpellStart( event )

	local ability = self
	local caster = ability:GetCaster()
	local target = ability:GetCursorPosition()
	local hero_position = caster:GetAbsOrigin()

	local placed_seals = caster.daggers
	
	local closest_seal = nil
	local min_dist = 1300
	local max_dist
	if caster:HasTalent("special_bonus_yondaime_body_flicker_global") then
		max_dist = 9999999 --Maximum allowed distance
	else
		max_dist = ability:GetSpecialValueFor("range") --Maximum allowed distance
	end
	
	for k,v in pairs(placed_seals) do
		if not v:IsNull() then
			local dist = target - v:GetAbsOrigin()
			
			if dist:Length2D() < min_dist then
			    if(	(caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() < max_dist) then
			    	min_dist = dist:Length2D()
				    closest_seal = v
				else
				    local distClose = caster:GetAbsOrigin() - v:GetAbsOrigin()
					
					if distClose:Length2D() < max_dist then
					    closest_seal = v
					end
			    end
			end
		end
	end

	if ( not closest_seal ) then
		ability:EndCooldown()
		caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
		return
	end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/yondaime/blink_core_alt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin()) -- Origin

-- Fire particle
	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/yondaime/blink_end_core.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 3, caster:GetAbsOrigin() )

	self:GetCaster():EmitSound("minato_flicker_end")
	
	caster:AddNoDraw()
	FindClearSpaceForUnit( caster, closest_seal:GetAbsOrigin(), true )
	caster:Stop()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
	caster:RemoveNoDraw()

end


function yondaime_body_flicker:CastFilterResultTarget( target )
	local ability = self
	local caster = ability:GetCaster()


	print(target:GetUnitName())


	-- Check illusion target
	if target:GetUnitName() == "npc_marked_kunai" then 
		return UF_SUCCESS
	else
		return UF_FAIL_CUSTOM
	end
	return ""
end
  
function yondaime_body_flicker:GetCustomCastErrorTarget( target )
	local ability = self
	local caster = ability:GetCaster()

	-- Check illusion target
	if target:GetUnitName() == "npc_marked_kunai" then 
		return ""
	else
		return "#error_must_target_owner_illusion"
	end
	return ""
end