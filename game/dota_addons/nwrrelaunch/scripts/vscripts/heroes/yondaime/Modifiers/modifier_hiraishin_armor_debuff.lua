modifier_hiraishin_armor_debuff = class({})

--------------------------------------------------------------------------------

function modifier_hiraishin_armor_debuff:IsHidden()
	return false
end

function modifier_hiraishin_armor_debuff:IsDebuff()
	return true
end

function modifier_hiraishin_armor_debuff:IsStunDebuff()
	return false
end

function modifier_hiraishin_armor_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_hiraishin_armor_debuff:OnCreated( kv )
	-- references
    local talent = self:GetAbility():GetCaster():FindAbilityByName("special_bonus_yondaime_4")
    self.armor_reduction = self:GetAbility():GetSpecialValueFor( "armor_reduction" ) -- special value
    
	if talent ~= nil then
        if talent:GetLevel() > 0 then
            self.armor_reduction = self.armor_reduction + talent:GetSpecialValueFor("value")
        end
	end
end

function modifier_hiraishin_armor_debuff:OnRefresh( kv )
    local talent = self:GetAbility():GetCaster():FindAbilityByName("special_bonus_yondaime_4")
    self.armor_reduction = self:GetAbility():GetSpecialValueFor( "armor_reduction" ) -- special value

    if talent:GetLevel() > 0 then
        self.armor_reduction = self.armor_reduction + talent:GetSpecialValueFor("value")
    end
end

function modifier_hiraishin_armor_debuff:OnDestroy( kv )
	
end

--------------------------------------------------------------------------------

function modifier_hiraishin_armor_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_hiraishin_armor_debuff:GetModifierPhysicalArmorBonus(keys)
    return self.armor_reduction
end


function modifier_hiraishin_armor_debuff:GetEffectName()
	return "particles/units/heroes/yondaime/yondaime_hiraishin_debuff.vpcf"
end

--------------------------------------------------------------------------------

function modifier_hiraishin_armor_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end