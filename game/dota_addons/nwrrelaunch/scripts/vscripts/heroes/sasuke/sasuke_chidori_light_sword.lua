sasuke_chidori_light_sword = sasuke_chidori_light_sword or class({})

LinkLuaModifier("modifier_chidori_light_sword_damage", "scripts/vscripts/heroes/sasuke/sasuke_chidori_light_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chidori_light_sword_debuff", "scripts/vscripts/heroes/sasuke/sasuke_chidori_light_sword.lua", LUA_MODIFIER_MOTION_NONE)

function sasuke_chidori_light_sword:GetAbilityTextureName()
	return "sasuke_chidori_light_sword"
end

function sasuke_chidori_light_sword:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function sasuke_chidori_light_sword:OnUpgrade()

	local caster = self:GetCaster()
	local ability = self
	
	ListenToGameEvent( "dota_player_used_ability", function( event )
			local player = PlayerResource:GetPlayer(event.PlayerID)
			-- Check if player existed
			if player then
				local hero = player:GetAssignedHero()
				-- Check if it is current hero
				if hero == caster then
					local ability_count = caster:GetAbilityCount()
					for i = 0, (ability_count - 1) do
						local ability_at_slot = caster:GetAbilityByIndex( i )
						if ability_at_slot and ability_at_slot:GetAbilityName() == event.abilityname then
							caster:AddNewModifier(caster, ability, "modifier_chidori_light_sword_damage", {})
							break
						end
					end
				end
			end
	end, nil)

end



modifier_chidori_light_sword_debuff = modifier_chidori_light_sword_debuff or class({})

function modifier_chidori_light_sword_debuff:IsHidden() return false end
function modifier_chidori_light_sword_debuff:IsDebuff() return true end

function modifier_chidori_light_sword_debuff:OnCreated(keys)

	print(self:GetAbility():GetSpecialValueFor("move_slow"))
	print(self:GetAbility():GetSpecialValueFor("attack_slow"))

end

function modifier_chidori_light_sword_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_chidori_light_sword_debuff:GetModifierAttackSpeedBonus_Constant()
    return  self:GetAbility():GetSpecialValueFor("move_slow")
end

function modifier_chidori_light_sword_debuff:GetModifierMoveSpeedBonus_Percentage()
    return  self:GetAbility():GetSpecialValueFor("attack_slow")
end

modifier_chidori_light_sword_damage = modifier_chidori_light_sword_damage or class({})

function modifier_chidori_light_sword_damage:IsHidden() return false end
function modifier_chidori_light_sword_damage:IsPassive() return true end

function modifier_chidori_light_sword_damage:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_chidori_light_sword_damage:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	self.impact_particle = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_thundering_flail/spirit_breaker_thundering_flail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(self.impact_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
end

function modifier_chidori_light_sword_damage:OnAttackLanded( keys )

		local target = keys.target
		local caster = keys.attacker

		--apply damage
		local damageTable = {
			victim = target,
			attacker = caster, 
			damage = self.ability:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}
		ApplyDamage(damageTable)  

		--add debuffmodifier
		target:AddNewModifier(caster, self.ability, "modifier_chidori_light_sword_debuff", {
			duration = self.ability:GetSpecialValueFor("duration")
		})

		--remove caster modifier
		caster:RemoveModifierByName("modifier_chidori_light_sword_damage")
end
