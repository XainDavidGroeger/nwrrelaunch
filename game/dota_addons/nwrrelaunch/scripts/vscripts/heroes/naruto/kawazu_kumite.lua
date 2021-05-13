--[[
  Author: LearningDave
  Date: October, 27th 2015
  -- Creates an Illusion, making use of the built in modifier_illusion
  outgoing and ingoing damage values are depending on 'naruto_kage_bunshin_mastery' ability lvl
]]
function ConjureImage( event )

  if event.caster:GetName() == "npc_dota_hero_dragon_knight" then
    EmitSoundOn("naruto_bunshin", event.caster)
  end

   if  event.caster.bunshinCount > 2 then
    event.caster.bunshins[0]:Destroy()
    event.caster.bunshins[0] = event.caster.bunshins[1]
    event.caster.bunshins[1] = event.caster.bunshins[2]
    event.caster.bunshinCount = event.caster.bunshinCount - 1
  end
     local target = event.target
     local caster = event.caster
     local player = caster:GetPlayerID()
     local ability = event.ability
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

     local hp_percentage = caster:GetHealth() / (caster:GetMaxHealth() / 100)
     local bunshin_hp = illusion:GetMaxHealth() / 100 * hp_percentage
     illusion:SetHealth(bunshin_hp)

     -- Set the unit as an illusion
     -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
     illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
     ability:ApplyDataDrivenModifier(caster, illusion, "modifier_naruto_bunshin_reduce_count", {duration = duration})

     -- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
     illusion:MakeIllusion()
    event.caster.bunshins[event.caster.bunshinCount] = illusion
     caster.bunshinCount = caster.bunshinCount + 1
     GameMode:RemoveWearables( illusion )

end

function initiateBunshinCount( keys )
  if keys.caster.bunshinCount == nil then
     keys.caster.bunshinCount = 0
  end
  if keys.caster.bunshins == nil then
     keys.caster.bunshins = {}
  end
end

function reduceBunshinCount( keys )
  keys.caster.bunshinCount = keys.caster.bunshinCount -1
end


function applyModifier( keys )
   --[[TODO: For now talent only changes duration.
             If we want in future to add stat changes we need to create lua modifier.
             it is more convenient than having to separate modifiers.
   ]]
   local ability = keys.ability
   local caster = keys.caster

   local naruto_modifier = keys.ModiferName

	local applied_modifier = ability:ApplyDataDrivenModifier(caster, caster, naruto_modifier, {})

   --If naruto has buuf duration talent
   if caster:FindAbilityByName("special_bonus_naruto_4") ~= nil then
      local duration_bonus_talent = keys.caster:FindAbilityByName("special_bonus_naruto_4")
      if duration_bonus_talent:IsTrained() then
         duration = ability:GetLevelSpecialValueFor('duration_special', ability:GetLevel())
         applied_modifier:SetDuration(duration, true)
      end
   end
  
   
end


function applyBunshinBuff(keys)
   local units = FindUnitsInRadius(
		keys.caster:GetTeamNumber(),
		keys.caster:GetAbsOrigin(),
		nil,
		900,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

   for i, individual_unit in ipairs(units) do
      if individual_unit:IsIllusion() and individual_unit:GetName() == "npc_dota_hero_dragon_knight" then

         keys.ability:ApplyDataDrivenModifier(
            keys.caster,
            individual_unit,
            "modifier_naruto_kawazu_kumite_bunshin_buff",
            {duration = 2}
         )

      end
   end

end