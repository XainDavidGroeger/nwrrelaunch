-- Creates an Illusion, making use of the built in modifier_illusion
function ConjureImage( event )

 local caster = event.caster
 local player = caster:GetPlayerID()
 local ability = event.ability
 local unit_name = caster:GetUnitName()
 local origin = caster:GetAbsOrigin() + RandomVector(100)
 local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
 local damage_percentage = ability:GetLevelSpecialValueFor( "damage_percentage", ability:GetLevel() - 1 )

 local illusion_max_hp_percentage = ability:GetLevelSpecialValueFor( "illusion_max_hp_percentage", ability:GetLevel()-1)
 local ability2 = caster:FindAbilityByName("special_bonus_kisame_2")
 if ability2 ~= nil then
	if ability2:IsTrained() then
		illusion_max_hp_percentage = illusion_max_hp_percentage + 10.0
	 end
 end



 caster:EmitSound("kisame_clone_cast")

 -- handle_UnitOwner needs to be nil, else it will crash the game.
 local illusion = CreateUnitByName("kisame_bunshin", origin, true, caster, nil, caster:GetTeamNumber())
 
 illusion:SetControllableByPlayer(player, true)
 illusion:SetOwner(caster)
 --if kisame has his ulti activated, his bunshin should turn into the shark model and have the water prison modifier
 if caster:HasModifier("modifier_kisame_metamorphosis") then 
    illusion:SetOriginalModel("models/kisame_shark/kisame_shark.vmdl")
	illusion:SetModelScale(1.0)
 end

if caster:GetName() == 'npc_dota_hero_beastmaster' then
	illusion:SetOriginalModel("models/kakashi_hd/kaka_hd_test.vmdl")
	illusion:SetModelScale(1.03)
end

 -- Set the unit as an illusion
 -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
ability:ApplyDataDrivenModifier(caster, illusion, "modifier_water_bunshin",  {duration = duration})
ability:ApplyDataDrivenModifier(caster, illusion, "modifier_water_bunshin_bonus_damage",  {duration = duration})

 
 GameMode:RemoveWearables( illusion )

illusion:SetForwardVector(caster:GetForwardVector())

-- add water prison (channeled hold) to bunshin
local ability_water = illusion:FindAbilityByName("kisame_bunshin_water_prison")
ability_water:SetAbilityIndex(0)
ability_water:SetLevel(event.ability:GetLevel())

-- add samehada passive to bunshin
local ability_samehada = illusion:FindAbilityByName("kisame_samehada_bunshin")
ability_samehada:SetAbilityIndex(1)
ability_samehada:SetLevel(event.ability:GetLevel())


 illusion:SetMaxHealth(caster:GetMaxHealth() / 100 * illusion_max_hp_percentage)

 local hp_caster_percentage = caster:GetHealth() / (caster:GetMaxHealth() / 100)
 illusion:SetHealth(illusion:GetMaxHealth() / 100 * hp_caster_percentage)

illusion:SetBaseDamageMin(caster:GetBaseDamageMin() / 100 * damage_percentage)
illusion:SetBaseDamageMax(caster:GetBaseDamageMax() / 100 * damage_percentage)


--local bonus_damage_preattack = caster:GetBonusDamageFromPrimaryStat() / 100 * damage_percentage
--caster:SetModifierStackCount( "modifier_water_bunshin_bonus_damage", ability, bonus_damage_preattack)

end
function NoDraw( keys )
  keys.caster:AddNoDraw()
  keys.ability.bunshins = {}
  keys.caster:Stop()


 local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
ParticleManager:SetParticleControl(particle, 0, keys.caster:GetAbsOrigin()) -- Origin

  keys.ability.bunshinParticle = particle
end


function draw( keys )
  local locationTable = {}
  local first = false
  local second = false
  local third = false
  local finished = false
  table.insert(locationTable, keys.caster:GetAbsOrigin())
  keys.caster:RemoveNoDraw()
  for key,oneBunshin in pairs(keys.ability.bunshins) do 
  	table.insert(locationTable, oneBunshin:GetAbsOrigin())
  	FindClearSpaceForUnit(oneBunshin, oneBunshin:GetAbsOrigin() + Vector(100, 100, 0), true)
  end
  local random = math.random()
  print("1")
    while not finished do
     	random = math.random()
     	print(random)
     	if random < 0.331 then
     		if not first then
     			FindClearSpaceForUnit(caster, locationTable[1], true)
     			finished = true
     			first = true
     		end
     	elseif random < 0.661 then
     		if not second then
	     		FindClearSpaceForUnit(caster, locationTable[2], true)
	     		finished = true
	     		second = true
     		end
     	elseif random < 1.01 then
     		if not third then
	     		FindClearSpaceForUnit(caster, locationTable[3], true)
	     		finished = true
	     		third = true
     		end
     	end
    end
    finished = false
    print("2")
     while not finished do
     	random = math.random()
     	print(random)
     	if random < 0.331 then
     		if not first then
     			FindClearSpaceForUnit(keys.ability.bunshins[1], locationTable[1], true)
     			finished = true
     			first = true
     		end
     	
     	elseif random < 0.661 then
     		if not second then
	     		FindClearSpaceForUnit(keys.ability.bunshins[1], locationTable[2], true)
	     		finished = true
	     		second = true
     		end
     	elseif random < 1.01 then
     		if not third then
	     		FindClearSpaceForUnit(keys.ability.bunshins[1], locationTable[3], true)
	     		finished = true
	     		third = true
	     	end
     	end
    end
    finished = false;
    print("3")

    while not finished do
     	random = math.random()
     	print(random)
     	print(first)
     	print(second)
     	print(third)
     	if random < 0.331 then
     		if not first then
     			FindClearSpaceForUnit(keys.ability.bunshins[2], locationTable[1], true)
     			finished = true
     			first = true
     		end
     	elseif random < 0.661 then
     		if not second then
	     		FindClearSpaceForUnit(keys.ability.bunshins[2], locationTable[2], true)
	     		finished = true
	     		second = true
     		end
     	
     	elseif random < 1.01 then
     		if not third then
	     		FindClearSpaceForUnit(keys.ability.bunshins[2], locationTable[3], true)
	     		finished = true
	     		third = true
	     	end
     	end
    end
    print("4")
 	keys.caster:RemoveNoDraw()
 	 for key,oneBunshin in pairs(keys.ability.bunshins) do 
 	 	oneBunshin:RemoveNoDraw()
  	end
    ParticleManager:DestroyParticle(keys.ability.bunshinParticle, true)
end

function RemoveBunshin( keys )
  keys.target:ForceKill(false)

  keys.target:EmitSound("bunshin_death")
    
    Timers:CreateTimer(0.1, function()
        keys.target:Destroy()
    end)
end


function removeModifier( keys )
  Timers:CreateTimer( 2, function()
      if keys.caster:HasModifier("mizu_bunshin_no_jutsu_illusion") then
        keys.caster:RemoveModifierByName("mizu_bunshin_no_jutsu_illusion")
      end
    return nil
  end)
end
