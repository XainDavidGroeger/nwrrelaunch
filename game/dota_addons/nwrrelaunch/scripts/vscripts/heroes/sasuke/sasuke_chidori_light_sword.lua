sasuke_chidori_light_sword = sasuke_chidori_light_sword or class({})

LinkLuaModifier("modifier_chidori_light_sword_damage", "scripts/vscripts/heroes/sasuke/sasuke_chidori_light_sword.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chidori_light_sword_debuff", "scripts/vscripts/heroes/sasuke/sasuke_chidori_light_sword.lua", LUA_MODIFIER_MOTION_NONE)

function sasuke_chidori_light_sword:Precache( context )
    PrecacheResource( "soundfile",   "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_chidori_light_sword_talking.vsndevts", context )
    PrecacheResource( "soundfile",   "soundevents/heroes/sasuke/sasuke_sword_impact.vsndevts", context )

    PrecacheResource( "particle", "particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/spirit_breaker/spirit_breaker_thundering_flail/spirit_breaker_thundering_flail.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", context )
end

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

	-- Ability properties
	if not self.ability then
		self:Destroy()
		return nil
	end

	self.parent = self:GetParent()

	self.impact_particle = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_thundering_flail/spirit_breaker_thundering_flail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(self.impact_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
end

function modifier_chidori_light_sword_damage:OnRemoved()
	ParticleManager:DestroyParticle(self.impact_particle, false)
end

function modifier_chidori_light_sword_damage:OnAttackLanded( keys )

	local attacker = keys.attacker

	if self.parent == attacker and attacker:GetTeamNumber() ~= target:GetTeamNumber() and not target:IsBuilding() then
		local target = keys.target
		local caster = keys.attacker
		local damage = self.ability:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_sasuke_1")

		target:EmitSound("sasuke_sword_impact")

		--apply damage
		local damageTable = {
			victim = target,
			attacker = caster, 
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}
		ApplyDamage(damageTable)  

		--add debuffmodifier
		target:AddNewModifier(caster, self.ability, "modifier_chidori_light_sword_debuff", {
			duration = self.ability:GetSpecialValueFor("duration")
		})

		

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_ABSORIGIN, target) 
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN, "attach_hitloc", target:GetAbsOrigin(), true)

		--remove caster modifier
		caster:RemoveModifierByName("modifier_chidori_light_sword_damage")
	end
	
end
