
temari_fusajin_no_jutsu = class({})

function temari_fusajin_no_jutsu:Precache( context )
    PrecacheResource( "particle",  "particles/units/heroes/temari/temari_dust_wind.vpcf", context )
end

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