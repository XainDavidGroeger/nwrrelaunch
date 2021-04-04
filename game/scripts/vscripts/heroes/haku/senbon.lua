


haku_crippling_senbon = haku_crippling_senbon or class({})

LinkLuaModifier("modifier_haku_endless_needles_victim", "heroes/haku/senbon.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_endless_needles_victim_special", "heroes/haku/senbon.lua", LUA_MODIFIER_MOTION_NONE)

function haku_crippling_senbon:GetAbilityTextureName()
	return "haku_crippling_senbon"
end


function haku_crippling_senbon:GetCooldown(iLevel)
	local cdrecution = 0
	if self:GetCaster():FindAbilityByName("special_bonus_haku_2"):GetLevel() > 0 then
		cdrecution = -2
	end
	return self.BaseClass.GetCooldown(self, iLevel) - cdrecution
end

function haku_crippling_senbon:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_haku_3"):GetLevel() > 0 then
		castrangebonus = 450
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function haku_crippling_senbon:OnSpellStart()

	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	local damage = self:GetSpecialValueFor("damage")
	local stun_duration = self:GetSpecialValueFor("stun_duration")


	-- Play sound
		caster:EmitSound("haku_senbon_cast")
	
	local projectile =
	{
		Target 				= self.target,
		Source 				= caster,
		Ability 			= self,
		EffectName 			= "particles/units/heroes/haku/senbon.vpcf",
		iMoveSpeed			= 2400,
		vSpawnOrigin 		= caster:GetAbsOrigin(),
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 10,
		bProvidesVision 	= true,
		iSourceAttachment 	= DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		iVisionRadius 		= 0,
		iVisionTeamNumber 	= caster:GetTeamNumber(),
		ExtraData			= {damage = damage, stun_duration = stun_duration}
	}
	ProjectileManager:CreateTrackingProjectile(projectile)

end


function haku_crippling_senbon:OnProjectileHit_ExtraData(target, location, ExtraData)
	if IsServer() then
		local caster = self:GetCaster()

		-- Play sound
		EmitSoundOnLocationWithCaster(location, "haku_senbon_impact", caster)
		caster:RemoveNoDraw()
		
		ApplyDamage({victim = target, attacker = caster, ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
		target:AddNewModifier(caster, self, "modifier_stunned", {duration = ExtraData.stun_duration * (1 - target:GetStatusResistance())})

		applyModifierFromAbility(self, self:GetCaster(), self.target)
	end
end

function applyModifierFromAbility( ability, caster, target )	
	local endless_wounds_stacks = ability:GetLevelSpecialValueFor("endless_wounds_stacks", ability:GetLevel() - 1 )
	local endless_wounds_ability = caster:FindAbilityByName("haku_endless_wounds")

	local abilityS2 = caster:FindAbilityByName("special_bonus_haku_1")

	if endless_wounds_ability:GetLevel() > 0 then
		local endless_wounds_threshold = endless_wounds_ability:GetLevelSpecialValueFor("threshold", endless_wounds_ability:GetLevel() - 1 )
		local endless_wounds_duration = endless_wounds_ability:GetLevelSpecialValueFor("duration", endless_wounds_ability:GetLevel() - 1 )


		if target:HasModifier("modifier_haku_endless_needles_victim") then
			local modifier_victim = target:FindModifierByName("modifier_haku_endless_needles_victim")
			local stacks = target:GetModifierStackCount(modifier_victim:GetName(),ability)
			if (stacks + endless_wounds_stacks) < endless_wounds_threshold then
				target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,stacks + endless_wounds_stacks)
			else
				target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,endless_wounds_threshold)
			end
		else
			if target:HasModifier("modifier_haku_endless_needles_victim_special") then
				local modifier_victim = target:FindModifierByName("modifier_haku_endless_needles_victim_special")
				local stacks = target:GetModifierStackCount(modifier_victim:GetName(),ability)
				if (stacks + endless_wounds_stacks) < endless_wounds_threshold then
					target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,stacks + endless_wounds_stacks)
				else
					target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,endless_wounds_threshold)
				end
			else
				if caster:FindAbilityByName("special_bonus_haku_1"):GetLevel() > 0 then
					target:AddNewModifier(caster, ability, "modifier_haku_endless_needles_victim_special", {duration = endless_wounds_duration})
					target:SetModifierStackCount("modifier_haku_endless_needles_victim_special", ability, endless_wounds_stacks)
				else
					target:AddNewModifier(caster, ability, "modifier_haku_endless_needles_victim", {duration = endless_wounds_duration})
					target:SetModifierStackCount("modifier_haku_endless_needles_victim", ability, endless_wounds_stacks)
				end
			end
		end	

		Timers:CreateTimer( endless_wounds_duration, function()
			if  target:HasModifier("modifier_haku_endless_needles_victim") then
			local modifier_victim = target:FindModifierByName("modifier_haku_endless_needles_victim")
			local stacks = target:GetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability)
				if (stacks - endless_wounds_stacks) > 0 then		
		        	target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,stacks - endless_wounds_stacks)
				else
					target:RemoveModifierByName("modifier_haku_endless_needles_victim")
				end
		    end

			if  target:HasModifier("modifier_haku_endless_needles_victim_special") then
				local modifier_victim = target:FindModifierByName("modifier_haku_endless_needles_victim_special")
				local stacks = target:GetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability)
					if (stacks - endless_wounds_stacks) > 0 then		
						target:SetModifierStackCount(modifier_victim:GetName(),endless_wounds_ability,stacks - endless_wounds_stacks)
					else
						target:RemoveModifierByName("modifier_haku_endless_needles_victim_special")
					end
			end
		return nil
		end
		)
	end
end


modifier_haku_endless_needles_victim = modifier_haku_endless_needles_victim or class({})

function modifier_haku_endless_needles_victim:IsHidden() return false end
function modifier_haku_endless_needles_victim:IsPurgable() return true end
function modifier_haku_endless_needles_victim:IsDebuff() return true end


function modifier_haku_endless_needles_victim:OnCreated()
	self.ability	= self:GetCaster():FindAbilityByName("haku_endless_wounds")
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	-- AbilitySpecials
	self.ms_slow_per_stack			= self.ability:GetSpecialValueFor("ms_slow_per_stack")
	self.duration				= self.ability:GetSpecialValueFor("duration")
	self.threshold				= self.ability:GetSpecialValueFor("threshold")

	self:SetStackCount(1)
end

function modifier_haku_endless_needles_victim:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_haku_endless_needles_victim:GetModifierMoveSpeedBonus_Percentage()
	local value = 0
	if self.caster:FindAbilityByName("special_bonus_haku_1"):GetLevel() > 0 then
		value = 0.25
	end
    return  self:GetStackCount() * (self.ms_slow_per_stack - value)
end


modifier_haku_endless_needles_victim_special = modifier_haku_endless_needles_victim_special or class({})

function modifier_haku_endless_needles_victim_special:IsHidden() return false end
function modifier_haku_endless_needles_victim_special:IsPurgable() return true end
function modifier_haku_endless_needles_victim_special:IsDebuff() return true end


function modifier_haku_endless_needles_victim_special:OnCreated()
	self.ability	= self:GetCaster():FindAbilityByName("haku_endless_wounds")
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	-- AbilitySpecials
	self.ms_slow_per_stack			= self.ability:GetSpecialValueFor("ms_slow_per_stack")
	self.duration				= self.ability:GetSpecialValueFor("duration")
	self.threshold				= self.ability:GetSpecialValueFor("threshold")

	self:SetStackCount(1)
end

function modifier_haku_endless_needles_victim_special:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_haku_endless_needles_victim_special:GetModifierMoveSpeedBonus_Percentage()
	local value = 0
	if self.caster:FindAbilityByName("special_bonus_haku_1"):GetLevel() > 0 then
		value = 0.25
	end
    return  self:GetStackCount() * (self.ms_slow_per_stack - value)
end
