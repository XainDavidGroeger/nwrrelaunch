function create( keys )
	local attack_min = keys.ability:GetLevelSpecialValueFor("attack_min", keys.ability:GetLevel() - 1)
	local attack_max = keys.ability:GetLevelSpecialValueFor("attack_max", keys.ability:GetLevel() - 1)
	local hp = keys.ability:GetLevelSpecialValueFor("hp", keys.ability:GetLevel() - 1)
	local radius = keys.ability:GetLevelSpecialValueFor("radius", keys.ability:GetLevel() - 1)
	local duration = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1)
	local target_point = keys.caster:GetAbsOrigin()
	local tree_count = keys.ability:GetLevelSpecialValueFor("count", keys.ability:GetLevel() - 1)
	local scope = math.pi * radius
	local posX = 0
	local posY = 0
	keys.caster:AddNoDraw()
	keys.ability:ApplyDataDrivenModifier(keys.caster,keys.caster,"modifier_haku_mirror_caster",{duration = duration})
	local r = radius / 2
	for i = 1,tree_count do
			posX = target_point.x + r * math.cos((math.pi*2/tree_count) * i)
			posY = target_point.y + r * math.sin((math.pi*2/tree_count) * i)
			local mirror = CreateUnitByName("npc_haku_mirror",Vector( posX, posY, 0.0 ),true,keys.caster,keys.caster,keys.caster:GetTeamNumber())

			mirror:SetHullRadius(48)
			FindClearSpaceForUnit(mirror, Vector( posX, posY, 0.0 ), false)
			if keys.ability:GetLevel() == 2 then
				mirror:CreatureLevelUp(1)
			end
			if keys.ability:GetLevel() == 3 then
				mirror:CreatureLevelUp(2)
			end
			mirror:SetBaseDamageMin(attack_min)
			mirror:SetBaseDamageMax(attack_max)
			mirror:SetMaxHealth(hp)
			mirror:SetHealth(hp)

			keys.ability:ApplyDataDrivenModifier(keys.caster,mirror,"modifier_haku_mirror_mirror",{})

			mirror:SetControllableByPlayer(keys.caster:GetPlayerID(), true)
			if keys.caster.mirrors  == nil then
				keys.caster.mirrors = {}
			end
			table.insert(keys.caster.mirrors, mirror)

			EmitSoundOn("Hero_Ancient_Apparition.IceVortex",mirror)

			local endless_wounds_ability = keys.caster:FindAbilityByName("haku_endless_wounds")
			if endless_wounds_ability:GetLevel() > 0 then
				endless_wounds_ability:ApplyDataDrivenModifier(keys.caster,mirror,"modifier_haku_endless_needles_caster",{})
			end
			local embrace = ParticleManager:CreateParticle("particles/units/heroes/haku/wyvern_cold_embrace_buff.vpcf", PATTACH_ABSORIGIN, mirror)
			ParticleManager:SetParticleControl(embrace, 0, mirror:GetAbsOrigin())
			ParticleManager:SetParticleControl(embrace, 1, mirror:GetAbsOrigin())
			ParticleManager:SetParticleControl(embrace, 2, mirror:GetAbsOrigin())

			Timers:CreateTimer( duration, function()
				if not mirror:IsNull() then
					mirror:RemoveSelf()
				end
				return nil
			end
			)
	end
	
	Timers:CreateTimer( duration, function()
		if not keys.caster:IsNull() then
			keys.caster:RemoveNoDraw()
		end
		return nil
	end
	)
end


function checkIfDeath( keys )
	local isDeath = true
	if keys.caster.mirrors then
		for _,mirror in pairs(keys.caster.mirrors) do
			if not mirror:IsNull() then
				if mirror:IsAlive() then
					isDeath = false
				else					
					--Dummy for mirror explosion particle
					local dummy = CreateUnitByName("npc_dummy_unit", mirror:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeam())
					dummy:AddNewModifier(keys.caster, nil, "modifier_phased", {})
					keys.ability:ApplyDataDrivenModifier(keys.caster, dummy, "modifier_haku_mirror_caster",nil)					
					--Create particle
					local explosion = ParticleManager:CreateParticle("particles/units/heroes/haku/mirror_destroy.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(explosion, 0, dummy:GetAbsOrigin())
					--Destroy mirror
					mirror:Destroy()				
					--Timer to destroy dummy
					Timers:CreateTimer({
						endTime = 0.25,
						callback = function()
							if not dummy:IsNull() then
								dummy:Destroy()
							end
						return nil
					end
					})					
				end
			end
		end
	end
	if isDeath then
		trackEnemy(keys)
		keys.caster:Kill(keys.ability, keys.ability.lastAttacker)
		keys.caster:RemoveNoDraw()
	end
end

function trackEnemy( keys )	
	if keys.ability.lastAttacker == nil then
		keys.ability.lastAttacker = keys.attacker
	else
		if keys.attacker:IsHero() then
			keys.ability.lastAttacker = keys.attacker
		end		
	end	
end

function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("haku_mirrors",keys.caster)
	elseif random == 2 then
		EmitSoundOn("haku_mirrors_2",keys.caster)
	end
end