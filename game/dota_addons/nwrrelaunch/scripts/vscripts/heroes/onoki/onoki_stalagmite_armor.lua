onoki_stalagmite_armor = class({})
LinkLuaModifier( "modifier_onoki_stalagmite_armor", "heroes/onoki/modifier_onoki_stalagmite_armor", LUA_MODIFIER_MOTION_NONE )

function onoki_stalagmite_armor:Precache( context )
	-- PrecacheResource( "soundfile", "xx.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_rocks.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_rocks_sand.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/onoki/onoki_rocks_shield.vpcf", context )
end

function onoki_stalagmite_armor:GetBehavior()
return self.BaseClass.GetBehavior(self)
end

function onoki_stalagmite_armor:GetCooldown(iLevel)
	local abilityScd = self:GetCaster():FindAbilityByName("special_bonus_onoki_2")
	local cdredusction = self.BaseClass.GetCooldown(self, iLevel) / 100 * 14
	if abilityScd:GetLevel() > 0 then
		return self.BaseClass.GetCooldown(self, iLevel) - cdredusction
	else
	    return self.BaseClass.GetCooldown(self, iLevel)
	end
end

function onoki_stalagmite_armor:GetCastRange(location, target)
return self:GetSpecialValueFor("cast_range")
end

-- function onoki_added_weight:CastFilterResultTarget(hTarget)
--     return UF_SUCCESS
-- end

--Starta
function onoki_stalagmite_armor:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	self.caster = caster
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	local rocks_particle = ParticleManager:CreateParticle("particles/units/heroes/onoki/onoki_rocks.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(rocks_particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)  --1
	local rocks_sand_particle = ParticleManager:CreateParticle("particles/units/heroes/onoki/onoki_rocks_sand.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(rocks_sand_particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)  --2
	
	target:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_onoki_stalagmite_armor", -- modifier name
        { duration = duration } -- kv
    )

    Timers:CreateTimer(duration, function ()
	    ParticleManager:DestroyParticle(rocks_particle, true)
		ParticleManager:DestroyParticle(rocks_sand_particle, true)
		ParticleManager:ReleaseParticleIndex(rocks_sand_particle)
		ParticleManager:ReleaseParticleIndex(rocks_particle)
	end)
end
