-- function applyDamage ( keys )

-- 	local ability = keys.ability
-- 	local caster = keys.caster
  
-- 	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
  
-- 	local ability1 = caster:FindAbilityByName("special_bonus_temari_1")
	
-- 	if ability1:IsTrained() then
-- 		damage = damage + 75
-- 	end
  
-- 	local damage_table = {
-- 	  victim = keys.target,
-- 	  attacker = keys.caster,
-- 	  damage = damage,
-- 	  damage_type = DAMAGE_TYPE_MAGICAL,		
-- 	  ability = keys.abiltiy
-- 	}
  
-- 	ApplyDamage( damage_table )

-- end


-- function resetCooldown( keys )

-- 	local ability2 = keys.caster:FindAbilityByName("special_bonus_temari_2")
-- 	if ability2:IsTrained() then
-- 		keys.ability:EndCooldown()
-- 		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1) - 2)
-- 	end

-- end


temari_fusajin_no_jutsu = class({})

function temari_fusajin_no_jutsu:ProcsMagicStick()
    return true
end

function temari_fusajin_no_jutsu:OnSpellStart()
	local caster = self:GetCaster()
	local projectile_data = {
		EffectName = "particles/units/heroes/temari/temari_wind_dust.vpcf",
		Ability = self,
		iMoveSpeed = self:GetSpecialValueFor("magic_missile_speed"),
		Source = caster,
		Target = self:GetCursorTarget(),
		bDodgeable = false,
		iSourceAttachment = "attach_right_hand",
		bProvidesVision = false,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iVisionRadius = 0,
	}

	ProjectileManager:CreateTrackingProjectile(projectile_data)

	local cd_reduction = self:GetSpecialValueFor("cooldown_reduction_other_abilities")
	local kamaitachi_ability = caster:FindAbilityByName("temari_kamaitachi_no_jutsu")
	if kamaitachi_ability:IsTrained() and not kamaitachi_ability:IsCooldownReady() then
		local left = kamaitachi_ability:GetCooldownTimeRemaining()
		kamaitachi_ability:EndCooldown()
		kamaitachi_ability:StartCooldown(left - cd_reduction)
	end


	local kiri_ability = caster:FindAbilityByName("temari_kuchiyose_kirikiri_mai")
	if kiri_ability:IsTrained() and not kiri_ability:IsCooldownReady() then
		local left = kiri_ability:GetCooldownTimeRemaining()
		kiri_ability:EndCooldown()
		kiri_ability:StartCooldown(left - cd_reduction)
	end

end

function temari_fusajin_no_jutsu:OnProjectileHit(target, location)
	local damage_table = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("damage"),
		damage_type = self:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = self
	}

	ApplyDamage(damage_table)
end

function temari_fusajin_no_jutsu:GetCooldown()
	if self:GetCaster():FindAbilityByName("special_bonus_temari_2"):GetLevel() > 0 then
		return 3
	else
		return 5
	end
end