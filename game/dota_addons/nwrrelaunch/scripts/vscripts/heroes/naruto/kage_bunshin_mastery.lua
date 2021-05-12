--[[
	Author: LearningDave
	Date: October, 27th 2015
	Swaps Position of Caster and his Illusion
]]
naruto_kage_bunshin_mastery = class({})

function naruto_kage_bunshin_mastery:GetCastRange(location, target)
	local castrangebonus = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_naruto_1")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	castrangebonus = 200
	    end
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function naruto_kage_bunshin_mastery:OnSpellStart( event )
	
		local ability = self
		local caster = ability:GetCaster()
		local target = ability:GetCursorTarget()
		local hero_position = caster:GetAbsOrigin()


		caster:AddNoDraw()
		target:AddNoDraw()
		FindClearSpaceForUnit( caster, target:GetAbsOrigin(), true )
		FindClearSpaceForUnit( target, hero_position, true )
		caster:RemoveNoDraw()
		target:RemoveNoDraw()


	--reset CD if special is skilled
	local abilityS2 = caster:FindAbilityByName("special_bonus_naruto_2")
	if abilityS2 ~= nil then
	    if abilityS2:IsTrained() then
	    	ability:EndCooldown()
	    	ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1) - 2 )
	    end
    end
end

--------------------------------------------------------------------------------
 --[[
	Author: LearningDave
	Date: October, 27th 2015
	Makes sure the target is an illusion of naruto's team //TODO MAKE SURE ILLUSION BELONGS TO NARUTO
]]
function naruto_kage_bunshin_mastery:CastFilterResultTarget( target )
	local ability = self
	local caster = ability:GetCaster()

	-- Check illusion target
	if target:IsIllusion() and target:GetTeamNumber() == caster:GetTeamNumber() and caster:GetName() == target:GetName() then 
		return UF_SUCCESS
	else
		return UF_FAIL_CUSTOM
	end
	return ""
end
  
function naruto_kage_bunshin_mastery:GetCustomCastErrorTarget( target )
	local ability = self
	local caster = ability:GetCaster()

	-- Check illusion target
	if target:IsIllusion() and target:GetTeamNumber() == caster:GetTeamNumber() and caster:GetName() == target:GetName() then 
		return ""
	else
		return "#error_must_target_owner_illusion"
	end
	return ""
end