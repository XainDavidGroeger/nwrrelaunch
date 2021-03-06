-- --[[Author: DigitalG
-- 	Date: April, 4th 2021.
-- ]]

hidan_cull_the_weak = class({})
LinkLuaModifier( "modifier_generic_custom_indicator",
				 "modifiers/modifier_generic_custom_indicator",
				 LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_hidan_cull_the_weak_ms_slow", 
				 "heroes/hidan/modifier_hidan_cull_the_weak_ms_slow.lua", 
				 LUA_MODIFIER_MOTION_NONE)

function hidan_cull_the_weak:GetIntrinsicModifierName()
	return "modifier_generic_custom_indicator"
end

function hidan_cull_the_weak:CreateCustomIndicator()
	local particle_cast = "particles/ui_mouseactions/range_finder_cone.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function hidan_cull_the_weak:UpdateCustomIndicator( loc )
	-- get data
	local origin = self:GetCaster():GetAbsOrigin()
	local cast_range = self:GetCastRange(loc, nil)
	local width = self:GetSpecialValueFor("pull_width")

	-- get direction
	local direction = loc - origin
	direction.z = 0
	direction = direction:Normalized()

	ParticleManager:SetParticleControl( self.effect_cast, 0, origin )
	ParticleManager:SetParticleControl( self.effect_cast, 1, origin)
	ParticleManager:SetParticleControl( self.effect_cast, 2, origin + direction*cast_range)
	ParticleManager:SetParticleControl( self.effect_cast, 3, Vector(width, width, 0))
	ParticleManager:SetParticleControl( self.effect_cast, 4, Vector(0, 255, 0)) --Color (green by default)
	ParticleManager:SetParticleControl( self.effect_cast, 6, Vector(1,1,1)) --Enable color change
end

function hidan_cull_the_weak:DestroyCustomIndicator()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function hidan_cull_the_weak:CastFilterResultLocation(location)
	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( location )
		end
	end

	return UF_SUCCESS
end

function hidan_cull_the_weak:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()

	local origin = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()
	local cast_range = self:GetCastRange(target_point, nil)
	local width = self:GetSpecialValueFor("pull_width")
	local final_target = origin+direction*cast_range


	targeted_units = FindUnitsInLine(caster:GetTeamNumber(),
									 origin, 
									 final_target, 
									 nil, 
									 width, 
									 DOTA_UNIT_TARGET_TEAM_ENEMY, 
									 DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
									 DOTA_UNIT_TARGET_FLAG_NONE)

	if #targeted_units ~= 0 then

		local hp_perc_cost = self:GetSpecialValueFor("hp_percentage_cost")
		local self_damage = (caster:GetMaxHealth()*hp_perc_cost/100)
		local non_lethal_self_damage_modifier = math.min((caster:GetHealth() - self_damage - 1), 0)

		local damageTable = {
			victim = caster,
			attacker = caster,
			damage = self_damage + non_lethal_self_damage_modifier,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage( damageTable )

		local hero_damage = self:GetSpecialValueFor("hero_damage")
		local creep_damage = self:GetSpecialValueFor("creep_damage")
		local duration = self:GetDuration()

		for key,oneTarget in pairs(targeted_units) do 
			-- keys.ability.hasTargets = true
			oneTarget:AddNewModifier(caster, 
									 self, 
									 "modifier_hidan_cull_the_weak_ms_slow", 
									 {Duration = duration})

			local pull_length = -1 * (( final_target - origin ):Length2D()) + 150
			local damage = 0
			if oneTarget:IsHero() then
				damage = hero_damage
			else 
				damage = creep_damage
			end
			local knockbackModifierTable =
			{
				should_stun = 0,
				knockback_duration = 0.3,
				duration = 0.3,
				knockback_distance = pull_length,
				knockback_height = 0,
				center_x = origin.x,
				center_y = origin.y,
				center_z = origin.z
			}
			oneTarget:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

			local damageTable = {
					victim = oneTarget,
					attacker = caster,
					damage = damage,
					damage_type = ability:GetAbilityDamageType()
				}
			ApplyDamage( damageTable )

		end
	end
end




