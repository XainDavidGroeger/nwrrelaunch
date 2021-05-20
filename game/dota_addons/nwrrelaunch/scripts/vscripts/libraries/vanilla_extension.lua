function CDOTA_BaseNPC:IsCustomHero()
	if GetKeyValueByHeroName(self:GetUnitName(), "IsCustom") and GetKeyValueByHeroName(self:GetUnitName(), "IsCustom") == 1 then
		return true
	end

	return false
end

-- Talent handling
function CDOTA_BaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end

	return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName, key)
	if self:HasAbility(talentName) then
		local value_name = key or "value"
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
	end

	return 0
end

function CDOTA_BaseNPC:HighestTalentTypeValue(talentType)
	local value = 0
	for i = 0, 23 do
		local talent = self:GetAbilityByIndex(i)
		if talent and string.match(talent:GetName(), "special_bonus_"..talentType.."_(%d+)") and self:FindTalentValue(talent:GetName()) > value then
			value = self:FindTalentValue(talent:GetName())
		end
	end

	return value
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = self:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then 
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

function CreateEmptyTalents(hero)
	for i = 1, 8 do
		local modifier_name = "modifier_special_bonus_"..hero.."_"..i

		LinkLuaModifier(modifier_name, "modifiers/modifier_custom_mechanics", LUA_MODIFIER_MOTION_NONE)  

		local class = modifier_name.." = class({IsHidden = function(self) return true end, RemoveOnDeath = function(self) return false end, AllowIllusionDuplicate = function(self) return true end, GetTexture = function(self) return 'naga_siren_mirror_image' end})"  
		load(class)()
	end
end

-- Call custom functions whenever CreateIllusions is being called anywhere
local original_CreateIllusions = CreateIllusions
CreateIllusions = function(hOwner, hHeroToCopy, hModifierKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace)
--	print("Create Illusions (override):", hOwner, hHeroToCopy, hModifierKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace)

	-- call the original function
	local response = original_CreateIllusions(hOwner, hHeroToCopy, hModifierKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace)

	for i = 1, #response do
		local illusion = response[i]

		if hModifierKeys.duration and type(hModifierKeys.duration) == "number" then
--			print("Add fail-safe kill target in "..hModifierKeys.duration.." seconds.")
			illusion:AddNewModifier(hOwner, nil, "modifier_kill", {duration = hModifierKeys.duration})
		end
	end

	return response
end

-- Checks if a given unit is Roshan
function CDOTA_BaseNPC:IsRoshan()
	if self:GetName() == "npc_imba_roshan" or self:GetName() == "npc_dota_roshan" or self:GetUnitLabel() == "npc_diretide_roshan" then
		return true
	else
		return false
	end
end
