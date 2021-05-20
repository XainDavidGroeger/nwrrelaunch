modifier_custom_mechanics = modifier_custom_mechanics or class({})

function modifier_custom_mechanics:IsHidden() return true end
function modifier_custom_mechanics:IsPurgable() return false end
function modifier_custom_mechanics:RemoveOnDeath() return false end

function modifier_custom_mechanics:OnCreated()
	-- should be called both client and server side
	local short_hero_name = string.gsub(self:GetParent():GetUnitName(), "npc_dota_hero_", "")
	CreateEmptyTalents(short_hero_name)
end
