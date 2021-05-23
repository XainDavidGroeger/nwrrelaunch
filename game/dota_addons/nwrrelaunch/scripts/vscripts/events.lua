-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.
-- Do not remove the GameMode:_Function calls in these events as it will mess with the internal barebones systems.

-- item relevant functions which are fired on events
require('items')
-- music.lua, relevant functions to control the music each will player will listen to/not listen to
require('music')
-- rescale.lua, relevant functions rescale the model sizes
require('rescale')
-- label.lua, relevant functions to modify the name/label of a player
require('label')
-- leaverGold.lua, relevant functions to modify gold income after some1 disconnects the game
require('leaverGold')

--cheats.lua, includes functions which listen to chat inputs of the players
require('cheats')

LinkLuaModifier("modifier_global_boost", "scripts/vscripts/modifiers/modifier_global_boost.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_courier_speed", "scripts/vscripts/modifiers/modifier_courier_speed.lua", LUA_MODIFIER_MOTION_NONE)

-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
	DebugPrint("[BAREBONES] GameRules State Changed")
	DebugPrintTable(keys)
	-- This internal handling is used to set up main barebones functions
	GameMode:_OnGameRulesStateChange(keys)

	local newState = GameRules:State_Get()

	--This function controls the music on each gamestate
	GameMode:PlayGameMusic(newState)

	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		GameMode:ChangeBuildings()
		VoiceResponses:Start()
	elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		GameMode:SetShops()
		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			if PlayerResource:IsValidPlayerID(i) then
				if not PlayerResource:HasSelectedHero(i) then
					PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
				end

				local overriden_hero_name = GetKeyValueByHeroName(PlayerResource:GetSelectedHeroName(i), "BaseClass")

				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), "set_strategy_time_hero_model", {
					sHeroName = overriden_hero_name,
				})
			end
		end
	elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
	    GameRules:SendCustomMessage("start_text_1", 0, 0)
		GameRules:SendCustomMessage("start_text_2", 0, 0)
	end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	
	if not npc or npc:GetClassname() == "npc_dota_thinker" or npc:IsPhantom() then
		return
	end

	--self:_OnNPCSpawned(keys)

	GameMode:RescaleUnit(npc)

	if GetMapName() == "turbo" then --If the map was selected turbo, then at the beginning of the game each courier is given a buff for speed, and the player is given a buff for experience and gold.
	    if npc.bFirstSpawned == false then
	        if npc:IsRealHero() then
		        npc:AddNewModifier(npc, nil, 'modifier_global_boost', nil) --Give players a buff for experience and gold
				print("add modifier_global_boost for players")
		    end
		    if npc:GetUnitName() == "npc_dota_courier" then --if it's a courier
	        	npc:AddNewModifier(npc, nil, 'modifier_courier_speed', nil) --Give courier a buff for ms
				print("add modifier_courier_speed for couriers")
	        end
			npc.bFirstSpawned = true
		end
	end
end

function GameMode:OnTakeDamage( keys )
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
	DebugPrint( '[BAREBONES] OnItemPurchased' )
	DebugPrintTable(keys)
		print("sd")
	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname 
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost
	
	local player = PlayerResource:GetPlayer(keys.PlayerID)

	if itemName == "item_forehead_protector" then
		GameMode:ForeheadProtectorOnItemPickedUp(player, itemName)
	end 

	if itemName == "item_flying_courier" then
		Timers:CreateTimer( 0.5, function()
			local flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_wings.vmdl")
			flying_courier:SetModelScale(1.2)
			return nil
		end)
	end 

	if itemName == "courier_radiant_flying" then
		Timers:CreateTimer( 0.5, function()
			local flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_dire.vmdl")
			flying_courier:SetModelScale(1.2)
			return nil
		end)
	end 
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
	DebugPrint('[BAREBONES] OnPlayerPickHero')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)

	if player ~= nil then
		local hero = player:GetAssignedHero()

		--hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later

		if hero ~= nil then
			local model = hero:FirstMoveChild()

			while model ~= nil do
				if model:GetClassname() == "dota_item_wearable" then
					model:AddEffects(EF_NODRAW) -- Set model hidden
					table.insert(hero.hiddenWearables, model)
				end
				model = model:NextMovePeer()
			end

			local heroClass = keys.hero
			local heroEntity = EntIndexToHScript(keys.heroindex)

			-- modifies the name/label of a player
			GameMode:setPlayerHealthLabel(player)
		end  
	end 
end

-- An entity died
function GameMode:OnEntityKilled( keys )
	DebugPrint( '[BAREBONES] OnEntityKilled Called' )
	DebugPrintTable( keys )

	GameMode:_OnEntityKilled( keys )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	--Items
	if killerEntity ~= nil then
		GameMode:SupportItemCooldownReset(killedUnit, killerEntity)
		GameMode:PlayKillSound(killerEntity, killedUnit)
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	DebugPrint('[BAREBONES] OnConnectFull')
	DebugPrintTable(keys)

	GameMode:_OnConnectFull(keys)
	
	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)
	
	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
	DebugPrint('[BAREBONES] OnItemCombined')
	DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end
	local player = PlayerResource:GetPlayer(plyID)

	-- The name of the item purchased
	local itemName = keys.itemname 
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost

	if itemName == "item_chakra_armor" then
		GameMode:ChakraArmorOnItemPickedUp(player, itemName)
	end
end

--[[
////////////////////////////////////////////////////////////////////////////////////////
	Listeners below are disabled in internal/gamemode.lua for performance purpose
////////////////////////////////////////////////////////////////////////////////////////
--]]

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
	DebugPrint( '[BAREBONES] OnItemPickedUp' )
	DebugPrintTable(keys)
	local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname

end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
	DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
	DebugPrintTable(keys)

	local abilityname = keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
	DebugPrint('[BAREBONES] OnPlayerChangedName')
	DebugPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
	DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local hero = player:GetAssignedHero()
	local abilityname = keys.abilityname

	-- add auto-generated modifier related to talent for client-side actions
	if string.find(abilityname, "special_bonus_") then
		hero:AddNewModifier(hero, nil, "modifier_"..abilityname, {})
	end
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
	DebugPrint('[BAREBONES] OnAbilityChannelFinished')
	DebugPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
	DebugPrint('[BAREBONES] OnPlayerLevelUp')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
	DebugPrint('[BAREBONES] OnLastHit')
	DebugPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	DebugPrint('[BAREBONES] OnTreeCut')
	DebugPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
	DebugPrint('[BAREBONES] OnRuneActivated')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune

	--[[ Rune Can be one of the following types
	DOTA_RUNE_DOUBLEDAMAGE
	DOTA_RUNE_HASTE
	DOTA_RUNE_HAUNTED
	DOTA_RUNE_ILLUSION
	DOTA_RUNE_INVISIBILITY
	DOTA_RUNE_BOUNTY
	DOTA_RUNE_MYSTERY
	DOTA_RUNE_RAPIER
	DOTA_RUNE_REGENERATION
	DOTA_RUNE_SPOOKY
	DOTA_RUNE_TURBO
	]]
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
	--DebugPrint("[BAREBONES] Entity Hurt")
	--DebugPrintTable(keys)

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	if keys.entindex_attacker ~= nil then
		local entCause = EntIndexToHScript(keys.entindex_attacker)
	end

	local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
	DebugPrint('[BAREBONES] AbilityUsed')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.PlayerID)
	local abilityname = keys.abilityname
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
	DebugPrint('[BAREBONES] OnTeamKillCredit')
	DebugPrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
	DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage
end

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
	DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
	DebugPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
	DebugPrint( '[BAREBONES] OnPlayerReconnect' )
	DebugPrintTable(keys) 

end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
	DebugPrint('[BAREBONES] PlayerConnect')
	DebugPrintTable(keys)
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
	DebugPrint('[BAREBONES] OnIllusionsCreated')
	DebugPrintTable(keys)

	local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
	DebugPrint('[BAREBONES] OnAbilityCastBegins')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)

	local gold = keys.gold
	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)

	local player = PlayerResource:GetPlayer(keys.player_id)
	local success = (keys.success == 1)
	local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)

	local goalEntity = EntIndexToHScript(keys.goal_entindex)
	local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
	local npc = EntIndexToHScript(keys.npc_entindex)
end