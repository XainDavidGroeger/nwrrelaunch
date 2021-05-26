--[[
  Author: LearningDave
  Date: October, 27th 2015
  -- Creates an Illusion, making use of the built in modifier_illusion
  outgoing and ingoing damage depends on 'naruto_kage_bunshin_mastery' lvl
]]
function CanBeReflected(bool, target, ability)
    if bool == true then
        if target:TriggerSpellReflect(ability) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function ConjureImage( event )
    local target = event.target
    local caster = event.caster
	local ability = event.ability
	
	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if target:FindModifierByName("modifier_item_lotus_orb_active") then
        CanBeReflected(false, target, ability)
        
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if target:TriggerSpellAbsorb(ability) then return end

  if event.caster.bunshinCount > 2 then
    event.caster.bunshins[0]:Destroy()
    event.caster.bunshins[0] = event.caster.bunshins[1]
    event.caster.bunshins[1] = event.caster.bunshins[2]
    event.caster.bunshinCount = event.caster.bunshinCount - 1
  end
    
    local player = caster:GetPlayerID()
    local unit_name = caster:GetUnitName()
    local origin = caster:GetAbsOrigin() + RandomVector(100)
    local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
    
    local outgoingDamage = 0
    local incomingDamage = 0
    
    if event.caster:HasAbility("naruto_kage_bunshin_mastery") then
      local ability_index = event.caster:FindAbilityByName("naruto_kage_bunshin_mastery"):GetAbilityIndex()
  if ability_index ~= nil then
          local kage_bunshin_mastery_ability = event.caster:GetAbilityByIndex(ability_index)
          if kage_bunshin_mastery_ability:GetLevel() > 0 then 
          
              outgoingDamage = kage_bunshin_mastery_ability:GetLevelSpecialValueFor( "illusion_outgoing_damage_percent", kage_bunshin_mastery_ability:GetLevel())
              if caster:FindAbilityByName("special_bonus_naruto_5") ~= nil then
                  local abilityS = event.caster:FindAbilityByName("special_bonus_naruto_5")
           if abilityS ~= nil then
                        if abilityS:IsTrained() then
                           outgoingDamage = outgoingDamage + 13
                        end
           end
              end
              
              incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage_percent", kage_bunshin_mastery_ability:GetLevel())
             
          else
          
          outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage_percent", 0)
          incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage_percent", 0)
          
          end
  end
   end

    -- handle_UnitOwner needs to be nil, else it will crash the game.
    local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
    illusion:SetPlayerID(caster:GetPlayerID())
    illusion:SetControllableByPlayer(player, true)

    -- Level Up the unit to the casters level
    local casterLevel = caster:GetLevel()
    for i=1,casterLevel-1 do
     illusion:HeroLevelUp(false)
    end

    -- Set the skill points to 0 and learn the skills of the caster
    illusion:SetAbilityPoints(0)
    for abilitySlot=0,15 do
     local ability = caster:GetAbilityByIndex(abilitySlot)
     if ability ~= nil then 
      local abilityLevel = ability:GetLevel()
      local abilityName = ability:GetAbilityName()
      local illusionAbility = illusion:FindAbilityByName(abilityName)
      if illusionAbility ~= nil then
       illusionAbility:SetLevel(abilityLevel)
      end
     end
    end

    -- Recreate the items of the caster
    for itemSlot=0,5 do
     local item = caster:GetItemInSlot(itemSlot)
     if item ~= nil then
      local itemName = item:GetName()
      local newItem = CreateItem(itemName, illusion, illusion)
      illusion:AddItem(newItem)
     end
    end

    illusion:SetHealth(caster:GetHealth())

    -- Set the unit as an illusion
    -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
    illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
    ability:ApplyDataDrivenModifier(caster, illusion, "modfiier_naruto_bunshin_reduce_count", {duration = duration})
    -- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
    illusion:MakeIllusion()
    event.caster.bunshins[event.caster.bunshinCount] = illusion
    caster.bunshinCount =  caster.bunshinCount + 1
    GameMode:RemoveWearables( illusion )
    Launch(event, illusion)


    local ability = event.ability
    local caster = event.caster
  
    --reset CD if special is skilled
    local ability7 = caster:FindAbilityByName("special_bonus_naruto_7")
	if ability7 ~= nil then
        if ability7:IsTrained() then
          ability:EndCooldown()
          ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1) - 4 )
        end
	end
end


function initiateBunshinCount( keys )
  if keys.caster.bunshinCount == nil then
     keys.caster.bunshinCount = 0
  end
   if keys.caster.bunshins == nil then
     keys.caster.bunshins = {}
  end
end

function applyDamage( keys )

  local ability = keys.ability
  local caster = keys.caster

	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))

	local ability3 = caster:FindAbilityByName("special_bonus_naruto_3")
    if ability3 ~= nil then
	    if ability3:IsTrained() then
	    	damage = damage + 90
	    end
	end

  local damage_table = {
    victim = keys.target,
    attacker = keys.caster,
    damage = damage,
    damage_type = DAMAGE_TYPE_MAGICAL,		
    ability = keys.abiltiy
  }

  ApplyDamage( damage_table )

end

function AddPhysics(caster)
  Physics:Unit(caster)
  caster:PreventDI(true)
  caster:SetAutoUnstuck(false)
  caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
  caster:FollowNavMesh(false) 
end

function RemovePhysics(caster)
  caster:SetPhysicsAcceleration(Vector(0,0,0))
  caster:SetPhysicsVelocity(Vector(0,0,0))
  caster:OnPhysicsFrame(nil)
  caster:PreventDI(false)
  caster:SetAutoUnstuck(true)
  caster:FollowNavMesh(true)
end

function FinishChidori(keys, illusion)
  local duration = keys.ability:GetLevelSpecialValueFor( "slow_duration", keys.ability:GetLevel() - 1)
  RemovePhysics(illusion)
  FindClearSpaceForUnit( illusion, illusion:GetAbsOrigin(), true )
  illusion:RemoveModifierByName("modifier_imba_storm_bolt_caster_hit")
  illusion:Stop()
  keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_naruto_bunshin_rasengan_slow", {duration = duration})
  print("apply damage")
end

function Launch(keys, illusion) 
  local target = keys.target
  local ability = keys.ability
  local ability_level = ability:GetLevel() - 1
  local velocity = ability:GetLevelSpecialValueFor("speed", ability_level)
  local sound_impact = keys.sound_impact
  local particle_impact = keys.particle_impact
  ability:ApplyDataDrivenModifier(keys.caster, illusion, "modifier_imba_storm_bolt_caster", {})
  AddPhysics(illusion)

  -- Movement
  Timers:CreateTimer(0, function()
    local vector = target:GetAbsOrigin() - illusion:GetAbsOrigin()
    local direction = vector:Normalized()
    if vector:Length2D() < 150 then
     illusion:RemoveModifierByName("modifier_imba_storm_bolt_caster")
     ability:ApplyDataDrivenModifier(keys.caster, illusion, "modifier_imba_storm_bolt_caster_hit", {})
    end
    illusion:SetPhysicsVelocity(direction * velocity)
    illusion:SetForwardVector(direction)
    if not target:IsAlive() then
      FinishChidori(keys)
      return nil
    elseif vector:Length2D() <= 2 * target:GetPaddedCollisionRadius() then
      local enemy_loc = target:GetAbsOrigin()
      local impact_pfx = ParticleManager:CreateParticle(particle_impact, PATTACH_POINT_FOLLOW, target)
      ParticleManager:SetParticleControl(impact_pfx, 0, enemy_loc)
      ParticleManager:SetParticleControlEnt(impact_pfx, 3, target, PATTACH_POINT_FOLLOW, "attach_origin", enemy_loc, true)
      FinishChidori(keys, illusion)
      CheckForSpellBlock(keys)
      target:EmitSound(sound_impact)
      return nil
    end
    return 0.03
  end)
end
