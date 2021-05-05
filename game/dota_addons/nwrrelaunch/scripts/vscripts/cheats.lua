WTF_MODE = false

CHEAT_CODES = {
    ["wtfmode"] = function() GameMode:Wtf() end,              -- "Toggles Wtf-mode: Gives all playes no cd on their abilities and 1k manareg"    
    ["gold"] = function(arg) GameMode:Gold(arg) end,              -- "Gives the player x gold"    
    ["repick"] = function(arg) GameMode:Repick(arg) end,              -- "Changes the Hero of the player"    
    ["lvlup"] = function(arg) GameMode:LvlUp(arg) end,                -- "The player lvlups x levels"        
    ["riseandshine"] = function() GameMode:RiseAndShine() end,        -- "Set time of day to dawn" 
    ["illu"] = function() GameMode:SpawnIllusionRune() end,        -- "Set time of day to dawn" 
    ["lightsout"] = function() GameMode:LightsOut() end,              -- "Set time of day to dusk"          
    ["reset"] = function() GameMode:ResetGameTime() end,              -- "Set time of day to dusk"          
    ["testmodus"] = function() GameMode:SpawnAllHeroes() end            -- "Set time of day to dusk"          
}

-- A player has typed something into the chat
function GameMode:SpawnAllHeroes()

    local player = PlayerResource:GetPlayer(0)
    local names = {
        "npc_dota_hero_hidan",  
        "npc_dota_hero_kisame",
        "npc_dota_hero_naruto",
        "npc_dota_hero_anko",
        "npc_dota_hero_guy",
        "npc_dota_hero_kakashi",
        "npc_dota_hero_haku",	
        "npc_dota_hero_raikage",
        "npc_dota_hero_sakura",
        "npc_dota_hero_madara",	
        "npc_dota_hero_zabuza",
        "npc_dota_hero_neji",
        "npc_dota_hero_yondaime",
        "npc_dota_hero_itachi",
        "npc_dota_hero_sasuke",
        "npc_dota_hero_gaara",
        "npc_dota_hero_kankuro",
        "npc_dota_hero_shikamaru",
        "npc_dota_hero_temari",
    }
    for nameCount = 1, 18 do
   --   local illusion = CreateUnitByName(names[nameCount], player:GetAbsOrigin(), true, player, nil, 2)
  --    illusion:SetHealth(10000)
  --    illusion:SetPlayerID(0)
     -- illusion:SetControllableByPlayer(0, true);
    end      
end 

-- A player has typed something into the chat
function GameMode:OnPlayerChat(keys)
	local text = keys.text
	local playerID = keys.userid-1
	local bTeamOnly = keys.teamonly
    local player = PlayerResource:GetPlayer(playerID)

    if text == 'malulubul' then
	    local steamId =   PlayerResource:GetSteamID(playerID)
        local t = {'76561198094209497', '76561197996145212', '76561198074948631', '76561198071444875', '76561197982043049', '76561199034723174'}
        for index = 1, 6 do
            if tostring(t[index]) == tostring(steamId) then
                for i = 0, 9 do
                    if PlayerResource:IsValidPlayerID(i) then
                        EmitSoundOnEntityForPlayer("malulubul", player:GetAssignedHero(), playerID)
                    end
                end
            end
        end
    end

    if CHEATS_ACTIVATED then
        
        GameMode:Setup_Hero_Tables()
        -- Handle '-command'
        if StringStartsWith(text, "-") then
            text = string.sub(text, 2, string.len(text))
        end

        local input = split(text)
        local command = input[1]
        if CHEAT_CODES[command] then
            CHEAT_CODES[command](input[2])
        end  
    end
      
end
function GameMode:SpawnIllusionRune(value)
    CreateRune(Vector(0,0,0), DOTA_RUNE_ILLUSION)
end
--[[Author: LearningDave
  Date: october, 30th 2015.
  Gives the Hero of the Player who typed 'lvlup x' x level ups
]]
function GameMode:LvlUp(value)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()
    if not value then value = 1 end
    
    local hero = PlayerResource:GetPlayer(pID):GetAssignedHero()

    for i=1, value do 
        hero:HeroLevelUp(true)
    end
    GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
end
--[[Author: LearningDave
  Date: october, 30th 2015.
  Gives the Hero of the Player who typed 'lvlup x' x level ups
]]
function GameMode:RiseAndShine()
    GameRules:SetTimeOfDay( 0.3 )
end
--[[Author: LearningDave
  Go to the future 60 seconds
]]
function GameMode:ResetGameTime()
    GameRules:ResetGameTime()
end
--[[Author: https://github.com/MNoya/DotaCraft/blob/01a29892b124f695cadd0a134afb8d056c83015a/game/dota_addons/dotacraft/scripts/vscripts/developer.lua
    Brings the light out!->Daytime
]]
function GameMode:LightsOut()
    GameRules:SetTimeOfDay( 0.8 )
end
--[[Author: LearningDave
    All players get 1000 manareg and have no cds
]]
function GameMode:Wtf()
    if WTF_MODE then
        WTF_MODE = false
    else
        WTF_MODE = true
    end
    local cmdPlayer = Convars:GetCommandClient()
    local PlayerCount = PlayerResource:GetPlayerCount() - 1
    if  WTF_MODE then
        Timers:CreateTimer( function()
            for i=0, PlayerCount do
                if PlayerResource:IsValidPlayer(i) then
                    local player = PlayerResource:GetPlayer(i)
                    
                    local hero = player:GetAssignedHero()
                 
					hero:SetBaseManaRegen(1000)
                    for i=0, hero:GetAbilityCount()-1 do 
                        if  hero:GetAbilityByIndex(i) ~= nil then
                            hero:GetAbilityByIndex(i):EndCooldown()
                        end
                    end
                    for i=0, 6 do 
                        if  hero:GetItemInSlot(i) ~= nil then
                            hero:GetItemInSlot(i):EndCooldown()
                        end
                    end
                end
            end
            if WTF_MODE then
                return 0.003
            else
                return nil
            end        
        end
        )   
    end
    if WTF_MODE then
        GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
    else
        GameRules:SendCustomMessage("Cheat disabled!", 0, 0)
    end
end
--[[Author: LearningDave
  Date: october, 30th 2015.
  Gives the Player x Gold (500 if no value given)
]]
function GameMode:Gold(value)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()
    if not value then value = 500 end
    PlayerResource:ModifyGold(pID, tonumber(value), true, 0)

    GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
end
--[[Author: LearningDave
  Date: november, 9th 2015.
  Gives the player a new hero
]]
function GameMode:Repick(value)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()
    if  value then   
        if tableContains(GameRules.nwrHeroTable, value) then
            local hero_index = getIndex(GameRules.nwrHeroTable, value)
            newHeroName = GameRules.heroTable[hero_index]
            PlayerResource:ReplaceHeroWith(pID, newHeroName, 0, 0)
        end
    end
   
end
--[[Author: LearningDave
  Date: november, 9th 2015.
  If not done yet, sets up hero tables to match naruto name to dota hero name
]]
function GameMode:Setup_Hero_Tables()
    -- setup race reference table
    if GameRules.heroTable == nil then
        GameRules.heroTable = {}
        GameRules.heroTable[1] = "npc_dota_hero_lion"
        GameRules.heroTable[2] = "npc_dota_hero_centaur"
        GameRules.heroTable[3] = "npc_dota_hero_doom_bringer"
        GameRules.heroTable[4] = "npc_dota_hero_itachi"
        GameRules.heroTable[5] = "npc_dota_hero_kakashi"
        GameRules.heroTable[6] = "npc_dota_hero_windrunner"
        GameRules.heroTable[7] = "npc_dota_hero_kunkka"
        GameRules.heroTable[8] = "npc_dota_hero_ogre_magi"
        GameRules.heroTable[9] = "npc_dota_hero_dragon_knight"
        GameRules.heroTable[10] = "npc_dota_hero_sven"
        GameRules.heroTable[11] = "npc_dota_hero_sand_king"
        GameRules.heroTable[12] = "npc_dota_hero_phantom_assassin"
        GameRules.heroTable[13] = "npc_dota_hero_storm_spirit"
        GameRules.heroTable[14] = "npc_dota_hero_juggernaut"
        GameRules.heroTable[15] = "npc_dota_hero_bloodseeker"
        GameRules.heroTable[16] = "npc_dota_hero_axe"
		GameRules.heroTable[17] = "npc_dota_hero_shadow_shaman"
        GameRules.heroTable[18] = "npc_dota_hero_anko"
    end
    if GameRules.nwrHeroTable == nil then
        GameRules.nwrHeroTable = {}
        GameRules.nwrHeroTable[1] = "gaara"
        GameRules.nwrHeroTable[2] = "guy"
        GameRules.nwrHeroTable[3] = "hidan"
        GameRules.nwrHeroTable[4] = "itachi"
        GameRules.nwrHeroTable[5] = "kakashi"
        GameRules.nwrHeroTable[6] = "kidoumaru"
        GameRules.nwrHeroTable[7] = "kisame"
        GameRules.nwrHeroTable[8] = "madara"
        GameRules.nwrHeroTable[9] = "naruto"
        GameRules.nwrHeroTable[10] = "onoki"
        GameRules.nwrHeroTable[11] = "raikage"
        GameRules.nwrHeroTable[12] = "sakura"
        GameRules.nwrHeroTable[13] = "sasuke"
        GameRules.nwrHeroTable[14] = "yondaime"
        GameRules.nwrHeroTable[15] = "zabuza"
        GameRules.nwrHeroTable[16] = "neji"
		GameRules.nwrHeroTable[17] = "shikamaru"
        GameRules.nwrHeroTable[18] = "anko"
    end
end



