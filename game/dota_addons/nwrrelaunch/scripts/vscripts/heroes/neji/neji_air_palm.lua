neji_air_palm = class({})
 LinkLuaModifier( "modifier_neji_air_palm_debuff", "scripts/vscripts/heroes/neji/neji_air_palm.lua", LUA_MODIFIER_MOTION_NONE )
 

function neji_air_palm:Precache( context )
    PrecacheResource( "soundfile",  "soundevents/heroes/neji/neji_air_palm_fire.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/heroes/neji/neji_air_palm_impact.vsndevts", context )

    PrecacheResource( "particle", "particles/units/heroes/haku/senbon.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/neji/neji_w_debuff_a.vpcf", context )
end

 function neji_air_palm:GetBehavior()
	 return self.BaseClass.GetBehavior(self)
 end
 
 function neji_air_palm:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
 end

 function neji_air_palm:GetCastRange(location, target)
	local castrangebonus = 0
	local abilityS = self:GetCaster():FindAbilityByName("special_bonus_neji_3")
	if abilityS ~= nil then
	    if abilityS:GetLevel() > 0 then
	    	castrangebonus = 450
	    end
	end
	return self:GetSpecialValueFor("cast_range") + castrangebonus
end
 
 function neji_air_palm:ProcsMagicStick()
    return true
end
 
 function neji_air_palm:OnSpellStart()
	
	self:GetCaster():EmitSound("neji_air_palm_fire")

	self.target = self:GetCursorTarget()
	self.caster = self:GetCaster()

	local projectile =
	{
		Target 				= self.target,
		Source 				= self.caster,
		Ability 			= self,
		EffectName 			= "particles/units/heroes/haku/senbon.vpcf",
		iMoveSpeed			= 2800,
		vSpawnOrigin 		= self.caster:GetAbsOrigin(),
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 10,
		bProvidesVision 	= true,
		iSourceAttachment 	= DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		iVisionRadius 		= 0,
		iVisionTeamNumber 	= self.caster:GetTeamNumber(),
		ExtraData			= {}
	}
	ProjectileManager:CreateTrackingProjectile(projectile)


 end

 function neji_air_palm:OnProjectileHit_ExtraData(target, location, ExtraData)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = caster:FindAbilityByName("haku_crippling_senbon")
		local damage = self:GetSpecialValueFor("damage")
		local duration = self:GetSpecialValueFor("duration")

		ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = self:GetAbilityDamageType()})
		target:AddNewModifier(caster, self, "modifier_neji_air_palm_debuff", {duration = duration})
		EmitSoundOn("neji_air_palm_impact", target) 
	end
end

 modifier_neji_air_palm_debuff = modifier_neji_air_palm_debuff or class({})

function modifier_neji_air_palm_debuff:IsHidden() return false end
function modifier_neji_air_palm_debuff:IsDebuff() return true end

function modifier_neji_air_palm_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_neji_air_palm_debuff:OnCreated()
	self.ms_slow = self:GetAbility():GetSpecialValueFor("ms_slow")
end

function modifier_neji_air_palm_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end