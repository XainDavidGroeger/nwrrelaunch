function C_DOTA_BaseNPC:HasTalent(talentName)
	if self:HasModifier("modifier_"..talentName) then
		return true 
	end

	return false
end

--Load ability KVs
local AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
	print(talentName, self:HasTalent(talentName))
	if self:HasModifier("modifier_"..talentName) then
		local value_name = key or "value"
		local specialVal = AbilityKV[talentName]["AbilitySpecial"]

		for l,m in pairs(specialVal) do
			if m[value_name] then
				return m[value_name]
			end
		end
	end

	return 0
end

function C_DOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = AbilityKV[self:GetName()]
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end

	if talentName and self:GetCaster():HasModifier("modifier_"..talentName) then 
		base = base + self:GetCaster():FindTalentValue(talentName) 
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
