kakashi_doton = kakashi_doton or class({})

function kakashi_doton:GetAbilityTextureName()
	return "kakashi_doton"
end

function kakashi_doton:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel) 
end

function kakashi_doton:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_kakashi_2"):GetLevel() > 0 then
		castrangebonus = 325
	end
	return self:GetSpecialValueFor("range") + castrangebonus
end

function kakashi_doton:OnSpellStart()

	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	local damage = self:GetSpecialValueFor("damage")
	local stun_duration = self:GetSpecialValueFor("stun_duration")

	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 3)

	local projectile =
	{
		Target 				= self.target,
		Source 				= caster,
		Ability 			= self,
		EffectName 			= "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
		iMoveSpeed			= 700,
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


function kakashi_doton:OnProjectileHit_ExtraData(target, location, ExtraData)
	if IsServer() then
		local caster = self:GetCaster()

		ApplyDamage({victim = target, attacker = caster, ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
		target:AddNewModifier(caster, self, "modifier_stunned", {duration = ExtraData.stun_duration * (1 - target:GetStatusResistance())})
	end
end



