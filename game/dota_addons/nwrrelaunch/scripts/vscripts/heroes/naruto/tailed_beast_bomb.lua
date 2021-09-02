
naruto_tailed_beast_bomb = naruto_tailed_beast_bomb or class({})

-------------------------------
-- naruto_tailed_beast_bomb --
-------------------------------

function naruto_tailed_beast_bomb:OnAbilityPhaseStart()
	EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Ability.PowershotPull", self:GetCaster())

	return true
end

function naruto_tailed_beast_bomb:OnSpellStart()
	-- Preventing projectiles getting stuck in one spot due to potential 0 length vector
	if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end

	self:FireBomb(channel_pct)
end

function naruto_tailed_beast_bomb:FireBomb()
	-- This "dummy" literally only exists to attach the gush travel sound to
	local powershot_dummy = CreateModifierThinker(self:GetCaster(), self, nil, {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
	powershot_dummy:EmitSound("Ability.Powershot")
	-- Keep track of how many units the Powershot will hit to calculate damage reductions
	powershot_dummy.units_hit = 0
	
	local powershot_particle = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
	
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

	ProjectileManager:CreateLinearProjectile({
		Source = self:GetCaster(),
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
		
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		
		EffectName = powershot_particle,
		fDistance = self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus(),
		fStartRadius = self:GetSpecialValueFor("arrow_width"),
		fEndRadius = self:GetSpecialValueFor("arrow_width"),
		vVelocity = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("arrow_speed") * Vector(1, 1, 0),
	
		bProvidesVision = true,
		iVisionRadius = self:GetSpecialValueFor("vision_radius"),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		
		ExtraData = {
			dummy_index			= powershot_dummy:entindex(),
			channel_pct			= channel_pct * 100
		}
	})
end

function naruto_tailed_beast_bomb:OnProjectileThink_ExtraData(location, data)
	if data.dummy_index then
		EntIndexToHScript(data.dummy_index):SetAbsOrigin(location)
	end
	
	GridNav:DestroyTreesAroundPoint(location, 75, true)
end

function naruto_tailed_beast_bomb:OnProjectileHit_ExtraData(target, location, data)
	if target and data.dummy_index and EntIndexToHScript(data.dummy_index) and not EntIndexToHScript(data.dummy_index):IsNull() and EntIndexToHScript(data.dummy_index).units_hit then
		EmitSoundOnLocationWithCaster(location, "Hero_Windrunner.PowershotDamage", self:GetCaster())
		
		local damage		= self:GetTalentSpecialValueFor("powershot_damage") * data.channel_pct * 0.01 * ((100 - self:GetSpecialValueFor("damage_reduction")) * 0.01) ^ EntIndexToHScript(data.dummy_index).units_hit
		local damage_type	= self:GetAbilityDamageType()
		
		-- IMBAfication: Godshot
		if data.channel_pct >= self:GetSpecialValueFor("godshot_min") and data.channel_pct <= self:GetSpecialValueFor("godshot_max") then
			damage		= self:GetTalentSpecialValueFor("powershot_damage") * self:GetSpecialValueFor("godshot_damage_pct") * 0.01
			damage_type	= DAMAGE_TYPE_PURE
			
			target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("godshot_stun_duration") * (1 - target:GetStatusResistance())})
		-- IMBAfication: Scattershot
		elseif data.channel_pct >= self:GetSpecialValueFor("scattershot_min") and data.channel_pct <= self:GetSpecialValueFor("scattershot_max") then
			damage		= self:GetTalentSpecialValueFor("powershot_damage") * self:GetSpecialValueFor("scattershot_damage_pct") * 0.01 * ((100 - self:GetSpecialValueFor("damage_reduction")) * 0.01) ^ EntIndexToHScript(data.dummy_index).units_hit
		end
		
		ApplyDamage({
			victim 			= target,
			damage 			= damage,
			damage_type		= damage_type,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self
		})
		
		EntIndexToHScript(data.dummy_index).units_hit = EntIndexToHScript(data.dummy_index).units_hit + 1
	elseif data.dummy_index then
		EntIndexToHScript(data.dummy_index):StopSound("Ability.Powershot")
		EntIndexToHScript(data.dummy_index):RemoveSelf()
	end
end
