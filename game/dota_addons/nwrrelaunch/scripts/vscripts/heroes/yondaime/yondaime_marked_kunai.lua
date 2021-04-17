yondaime_marked_kunai = yondaime_marked_kunai or class({})
LinkLuaModifier( "modifier_marked_kunai_debuff", "heroes/yondaime/yondaime_marked_kunai.lua" , LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marked_kunai_bonus", "heroes/yondaime/yondaime_marked_kunai.lua" , LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marked_kunai", "heroes/yondaime/yondaime_marked_kunai.lua" , LUA_MODIFIER_MOTION_NONE )


function yondaime_marked_kunai:GetAbilityTextureName()
	return "yondaime_marked_kunai"
end

function yondaime_marked_kunai:GetCooldown(iLevel)
	local cdreduction = 0
	if self:GetCaster():FindAbilityByName("special_bonus_yondaime_1"):GetLevel() > 0 then
		cdreduction = 1
	end
	return self.BaseClass.GetCooldown(self, iLevel) - cdreduction
end

function yondaime_marked_kunai:GetCastRange(location, target)
	local castrangebonus = 0
	if self:GetCaster():FindAbilityByName("special_bonus_yondaime_2"):GetLevel() > 0 then
		castrangebonus = 300
	end
	return self.BaseClass.GetCastRange(self, location, target) + castrangebonus
end

function yondaime_marked_kunai:OnSpellStart()

	local caster = self:GetCaster()
	local ability = self
	local casterOrigin = caster:GetAbsOrigin()
	local targetPos = self:GetCursorPosition()
	local direction = targetPos - casterOrigin
	local dagger_radius = ability:GetSpecialValueFor("dagger_radius")
	local distance = math.sqrt(direction.x * direction.x + direction.y * direction.y)
	local speed = ability:GetSpecialValueFor("dagger_speed")

	if caster.daggers == nil then
		caster.daggers = {}
	end

	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")


	self.ability = self
	self.caster = caster
	self.creep_damage = self.ability:GetSpecialValueFor("creep_damage")
	self.hero_damage = self.ability:GetSpecialValueFor("hero_damage")

	caster.isDC = true
	direction = direction / direction:Length2D()

	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= "particles/units/heroes/yondaime/kunai_alt.vpcf",
		vSpawnOrigin		= casterOrigin,
		fDistance			= distance,
		fStartRadius		= dagger_radius,
		fEndRadius			= dagger_radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
	--	fExpireTime			= ,
		bDeleteOnHit 		= false,
		vVelocity			= direction * speed,
		bProvidesVision		= false,
		iVisionRadius		= 300,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )
end

function yondaime_marked_kunai:OnUpgrade()
	local flicker = self:GetCaster():FindAbilityByName("yondaime_body_flicker")
	flicker:SetLevel( self:GetCaster():FindAbilityByName("yondaime_marked_kunai"):GetLevel())
end

function yondaime_marked_kunai:OnProjectileHit(hTarget, vLocation)

	if hTarget == nil then 

		-- Variables
		local caster = self.caster
		local ability = self.ability
		local target_point = vLocation

		self.buff_duration = self.ability:GetSpecialValueFor("duration")
	
		-- Special Variables
		local duration = ability:GetSpecialValueFor("dagger_duration")
	
		-- Dummy
		local dummy = CreateUnitByName("npc_marked_kunai", target_point, false, caster, caster, caster:GetTeam())
		dummy:SetOriginalModel("models/yondaime_new/yondakunai.vmdl")
		dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		dummy:SetModelScale(4.0)
		dummy:AddNewModifier(caster, ability, "modifier_marked_kunai_bonus", {duration = duration})
	
		-- dummy:SetUnitName("npc_marked_kunai")
	
		table.insert(self.caster.daggers, dummy)
		ability.kunai = dummy
	
		local particle = ParticleManager:CreateParticle("particles/units/heroes/yondaime/kunai_ground.vpcf", PATTACH_POINT_FOLLOW, dummy) 
		ParticleManager:SetParticleControlEnt(particle, 0, dummy, PATTACH_POINT_FOLLOW, "attach_origin", dummy:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, dummy, PATTACH_POINT_FOLLOW, "attach_origin", dummy:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 3, dummy, PATTACH_POINT_FOLLOW, "attach_origin", dummy:GetAbsOrigin(), true)
	
		local kunai_duration = ability:GetLevelSpecialValueFor("dagger_duration", (ability:GetLevel() - 1))
	
		Timers:CreateTimer( kunai_duration, function()
					dummy:RemoveSelf()
					return nil
		end
		)
		return
	end

	if hTarget:IsBuilding() then
		return
	end

	hTarget:EmitSound("Hero_PhantomAssassin.Dagger.Target")

	if hTarget:IsRealHero() then
		ApplyDamage({ victim =hTarget, attacker = self.caster, damage = self.hero_damage, damage_type = DAMAGE_TYPE_MAGICAL })
	else
		ApplyDamage({ victim =hTarget, attacker = self.caster, damage = self.creep_damage, damage_type = DAMAGE_TYPE_MAGICAL })
	end

	hTarget:AddNewModifier(self.caster, self.ability, "modifier_marked_kunai_debuff", {duration = self.buff_duration})

	hTarget:AddNewModifier(self.caster, self.ability, "modifier_marked_kunai_debuff", {duration = self.buff_duration})

end


modifier_marked_kunai_debuff = class({})

--------------------------------------------------------------------------------

function modifier_marked_kunai_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

function modifier_marked_kunai_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end


--[[ ============================================================================================================
    Author: Dave
    Date: October 24, 2015
    -- adds a modifier which slows the target on x percent(depening on the 'neji_byakugan' level)
================================================================================================================= ]]
function modifier_marked_kunai_debuff:GetModifierPhysicalArmorBonus(keys)
    return self:GetAbility():GetSpecialValueFor( "armor_reduction")
end


--------------------------------------------------------------------------------

modifier_marked_kunai = class({})

function modifier_marked_kunai:IsBuff()
	return true
end

function modifier_marked_kunai:IsAura()						
	return true 
end
function modifier_marked_kunai:IsAuraActiveOnDeath() 		
	return false 
end

function modifier_marked_kunai:GetAuraDuration()			
	return 0.1 
end

function modifier_marked_kunai:GetAuraRadius()				
	return self.radius 
end

function modifier_marked_kunai:GetAuraSearchFlags()			
	return DOTA_UNIT_TARGET_FLAG_NONE 
end

function modifier_marked_kunai:GetAuraSearchTeam()			
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_marked_kunai:GetAuraSearchType()			
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP 
end

function modifier_marked_kunai:GetModifierAura()			
	return "modifier_marked_kunai_bonus" 
end


modifier_marked_kunai_bonus = class({})

function modifier_marked_kunai_bonus:IsPassive()
	return true
end

function modifier_marked_kunai_bonus:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
end
