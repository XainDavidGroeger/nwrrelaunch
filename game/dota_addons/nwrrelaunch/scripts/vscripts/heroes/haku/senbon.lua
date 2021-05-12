haku_crippling_senbon = haku_crippling_senbon or class({})

LinkLuaModifier("modifier_haku_endless_needles_victim", "heroes/haku/endless_wounds.lua", LUA_MODIFIER_MOTION_NONE)


function haku_crippling_senbon:GetAbilityTextureName()
	return "haku_crippling_senbon"
end

function haku_crippling_senbon:GetCooldown(iLevel)
	local cdrecution = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_haku_2")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	cdrecution = 2
	    end
	end
	return self.BaseClass.GetCooldown(self, iLevel) - cdrecution
end

function haku_crippling_senbon:GetCastRange(location, target)
	local castrangebonus = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_haku_3")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	castrangebonus = 450
	    end
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function haku_crippling_senbon:CanBeReflected(bool, target)
	if bool == true then
        if target:TriggerSpellReflect(self) then return end
	else
	    --[[ simulate the cancellation of the ability if it is not reflected ]]
	    ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
		EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
	end
end

function haku_crippling_senbon:OnSpellStart()

	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	local damage = self:GetSpecialValueFor("damage")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if self.target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(true, self.target)
		
        return
    end
	
	--[[ if the target has Linken's Sphere, cancels the use of the ability ]]
	if self.target:TriggerSpellAbsorb(self) then return end

	-- Play sound
	caster:EmitSound("haku_senbon_cast")
	caster:EmitSound("haku_senbon")
	
	local projectile =
	{
		Target 				= self.target,
		Source 				= caster,
		Ability 			= self,
		EffectName 			= "particles/units/heroes/haku/haku_crippling_senbon.vpcf",
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
		local ability = caster:FindAbilityByName("haku_crippling_senbon")

		-- Play sound
		EmitSoundOnLocationWithCaster(location, "haku_senbon_impact", caster)
		caster:RemoveNoDraw()
		
		ApplyDamage({victim = target, attacker = caster, ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
		target:AddNewModifier(caster, self, "modifier_stunned", {duration = ExtraData.stun_duration * (1 - target:GetStatusResistance())})

		local woudns_ability = caster:FindAbilityByName("haku_endless_wounds")
		if not woudns_ability == nil then
		    if woudns_ability:GetLevel() > 0 then
		    	local endless_wounds_stacks = ability:GetSpecialValueFor("endless_wounds_stacks")
		    	woudns_ability:ApplyStacks(target, endless_wounds_stacks)
		    end
		end
	end
end



