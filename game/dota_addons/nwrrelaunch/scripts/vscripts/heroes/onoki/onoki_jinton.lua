onoki_jinton = class({})

function onoki_jinton:Precache( context )
    PrecacheResource( "soundfile", "soundevents/onoki_jinton.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/onoki_atomic_root.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/onoki_atomic_explosion.vsndevts", context )
    PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_cube1.vpcf", context )
end

function onoki_jinton:GetBehavior()
return self.BaseClass.GetBehavior(self)
end

function onoki_jinton:GetCooldown(iLevel)
	local abilityScd = self:GetCaster():FindAbilityByName("special_bonus_onoki_2")
	local cdredusction = self.BaseClass.GetCooldown(self, iLevel) / 100 * 14
	if abilityScd:GetLevel() > 0 then
		return self.BaseClass.GetCooldown(self, iLevel) - cdredusction
	else
	    return self.BaseClass.GetCooldown(self, iLevel)
	end
end

function onoki_jinton:GetCastRange(location, target)
local abilityS = self:GetCaster():FindAbilityByName("special_bonus_onoki_1")
if abilityS:GetLevel() > 0 then
	return self:GetSpecialValueFor("cast_range") + 225
else
    return self:GetSpecialValueFor("cast_range")
end
end

function onoki_jinton:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local targetOrigin = target:GetAbsOrigin()
	local root_duration = self:GetSpecialValueFor("root_duration")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local damage_type = self:GetAbilityDamageType()
	local abilitySpec = self:GetCaster():FindAbilityByName("special_bonus_onoki_5")
	
    if abilitySpec:IsTrained() then
    	damage = damage + 100
		damage_type = DAMAGE_TYPE_PURE
    end
	
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		targetOrigin,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	
	for _,enemy in pairs(enemies) do
		-- initial damage (deprecated)
		if not enemy:IsMagicImmune() then
		    enemy:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_rooted", -- modifier name
                { duration = root_duration } -- kv
            )
			self:PlayEffects(enemy)
		end
	end
	
	EmitSoundOn("onoki_jinton", caster)
	caster:EmitSound("onoki_particle_talking")
	EmitSoundOn("onoki_atomic_root", target)
	
	Timers:CreateTimer(root_duration - 0.25, function ()
	    EmitSoundOn("onoki_atomic_explosion", target)
	
	    local enemiesDelayd = FindUnitsInRadius(
	    	caster:GetTeamNumber(),	-- int, your team number
		    targetOrigin,	-- point, center point
		    nil,	-- handle, cacheUnit. (not known)
		    radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		    0,	-- int, order filter
		    false	-- bool, can grow cache
	    )
	
		for _,enemyDelayd in pairs(enemiesDelayd) do
		    if not enemyDelayd:IsMagicImmune() then
		        enemyDelayd:StartGestureWithPlaybackRate(ACT_DOTA_DIE, 1.5)
		        
                enemyDelayd:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "modifier_stunned", -- modifier name 
                    { duration = stun_duration } -- kv
                )
	            
	            ApplyDamage({ victim = enemyDelayd, attacker = caster, damage = damage, damage_type = damage_type })
			end
		end
	end)
end

function onoki_jinton:PlayEffects(targets) --point, radius (for ult)
	local jinton_particle = ParticleManager:CreateParticle("particles/units/heroes/onoki/onoki_cube1.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(jinton_particle, 0, targets:GetAbsOrigin())
	
	Timers:CreateTimer(2, function ()
	    ParticleManager:DestroyParticle(jinton_particle, true)
		ParticleManager:ReleaseParticleIndex(jinton_particle)
	end)
end