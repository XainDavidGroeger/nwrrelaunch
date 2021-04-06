modifier_special_bonus_str_lua = class({})

-- modifier_antimage_spell_shield_lua.lua
function modifier_special_bonus_str_lua:OnCreated( kv )
    DebugPrint("create str modifier")
    DebugPrint(self:GetAbility():GetSpecialValueFor("bonus_str"))
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_special_bonus_str_lua:OnRefresh( kv )
    DebugPrint("refresh str modifier")
    DebugPrint(self:GetAbility():GetSpecialValueFor("bonus_str"))
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_special_bonus_str_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}

	return funcs
end

function modifier_special_bonus_str_lua:GetStatsStrengthBonus( params )
    DebugPrint('fire GetStatsStrengthBonus')
	return self.bonus
end