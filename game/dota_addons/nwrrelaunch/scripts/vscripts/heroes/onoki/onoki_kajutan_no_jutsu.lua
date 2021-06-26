onoki_kajutan_no_jutsu = class({})

function onoki_kajutan_no_jutsu:Precache( context )
    PrecacheResource( "soundfile", "soundevents/heroes/onoki/onoki_ultimate_pulse.vsndevts", context )
    PrecacheResource( "soundfile", "sounds/weapons/hero/elder_titan/echo_stomp_cast.vsnd", context )
    PrecacheResource( "soundfile", "soundevents/heroes/onoki/onoki_ulti_talking.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/onoki_ult_end.vsndevts", context )
    PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_kajutan_no_jutsu.vpcf", context )
end

function onoki_kajutan_no_jutsu:GetBehavior()
return self.BaseClass.GetBehavior(self)
end

function onoki_kajutan_no_jutsu:GetCooldown(iLevel)
	local abilityScd = self:GetCaster():FindAbilityByName("special_bonus_onoki_2")
	local cdredusction = self.BaseClass.GetCooldown(self, iLevel) / 100 * 14
	if abilityScd ~= nil then
	    if abilityScd:GetLevel() > 0 then
	    	return self.BaseClass.GetCooldown(self, iLevel) - cdredusction
	    else
	        return self.BaseClass.GetCooldown(self, iLevel)
	    end
	end
end

function onoki_kajutan_no_jutsu:GetCastRange(location, target)
return self:GetSpecialValueFor("range")
end

function onoki_kajutan_no_jutsu:ProcsMagicStick()
    return true
end

function onoki_kajutan_no_jutsu:OnSpellStart()
	local caster = self:GetCaster()
	local casterOrigin = caster:GetOrigin()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	local damage_delay = self:GetSpecialValueFor("damage_delay")
	local threshold_factor = self:GetSpecialValueFor("threshold_factor")
	local damage_factor = self:GetSpecialValueFor("damage_factor")
	local abilitySpec = self:GetCaster():FindAbilityByName("special_bonus_onoki_6")
	
	if abilitySpec ~= nil then
        if abilitySpec:IsTrained() then
        	threshold_factor = threshold_factor + 0.04
        end
	end

	caster:EmitSound("onoki_ulti_talking")
	
	local timerDur = 0
	Timers:CreateTimer(0.0, function ()
	    if timerDur < duration then
	        timerDur = timerDur + 1
			if timerDur == duration then
				damage_factor = damage_factor + self:GetSpecialValueFor("last_wave_bonus_damage")
			end
	        local enemiesDelayd = FindUnitsInRadius(
	        	caster:GetTeamNumber(),	-- int, your team number
	        	casterOrigin,	-- point, center point
	        	nil,	-- handle, cacheUnit. (not known)
	        	radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
	        	DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
	        	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
	        	DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
	        	0,	-- int, order filter
	        	false	-- bool, can grow cache
	        )
		    
			self:PlayEffects()
	        
		    for _,enemyDelayd in pairs(enemiesDelayd) do
		        local max_life = enemyDelayd:GetMaxHealth() 
	            local threshold = max_life * threshold_factor
	            local current_life = enemyDelayd:GetHealth()
	            local damage = max_life * damage_factor --maybe can bugs, but I don't think so
	            local damage_type = self:GetAbilityDamageType()
		        
	            if current_life <= threshold then
	            	damage = enemyDelayd:GetMaxHealth() * threshold_factor
					print("threshold")
	            end
	            local currenthppercent = enemyDelayd:GetHealth() / (enemyDelayd:GetMaxHealth() / 100)
	            print(currenthppercent)
                
	            --ParticleManager:CreateParticle("particles/blood_impact/blood_advisor_pierce_spray.vpcf", PATTACH_POINT, target)
	            ApplyDamage({ victim = enemyDelayd, attacker = caster, damage = damage, damage_type = damage_type })
		    end
			
			if timerDur == 5 then
		        if RollPercentage(20) then
				    self:PlayEndSound()
				end
			end
		end
		
		return damage_delay
	end)
end

function onoki_kajutan_no_jutsu:PlayEffects()
    local caster = self:GetCaster()
    local echoes_particle = ParticleManager:CreateParticle("particles/units/heroes/onoki/onoki_kajutan_no_jutsu.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(echoes_particle, 0, caster:GetAbsOrigin())
	
	self:GetCaster():EmitSound("onoki_ultimate_pulse")
	
	Timers:CreateTimer(0.86, function ()
	    ParticleManager:DestroyParticle(echoes_particle, true)
		ParticleManager:ReleaseParticleIndex(echoes_particle)
	end)
end

function onoki_kajutan_no_jutsu:PlayEndSound()
    local caster = self:GetCaster()
    
	EmitSoundOn("onoki_ult_end", self:GetCaster())
end