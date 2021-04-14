function GameMode:setPlayerHealthLabel( player )
	if PlayerResource:IsValidPlayerID(player:GetPlayerID()) then
		if not PlayerResource:IsBroadcaster(player:GetPlayerID()) and PlayerResource:GetPlayer(player:GetPlayerID()) and PlayerResource:GetPlayer(player:GetPlayerID()).GetAssignedHero and PlayerResource:GetPlayer(player:GetPlayerID()):GetAssignedHero() then
			local player_hero = PlayerResource:GetPlayer(player:GetPlayerID()):GetAssignedHero()

			--dave
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 133943769 then
				player_hero:SetCustomHealthLabel("Mod Creator", 30, 144, 255)
			end

			--neil
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 148677144 then
				player_hero:SetCustomHealthLabel("Map Creator", 192, 30, 255)
			end

			--jaze
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 21777321 then
				player_hero:SetCustomHealthLabel("Graphic Designer", 12, 70, 110)
			end

			--digital
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 114682903 then
				player_hero:SetCustomHealthLabel("Map Creator", 0, 255, 255)
			end

			--muzk
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 99391993 then
				player_hero:SetCustomHealthLabel("NWU Creator", 41, 58, 212)
			end

			--spastic
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 35879484 then
				player_hero:SetCustomHealthLabel("The Genin", 255, 140, 0)
			end

			--lucci
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 93546854 then
				player_hero:SetCustomHealthLabel("Best Player", 30, 144, 255)
			end

			--taggin
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 59452361 then
				player_hero:SetCustomHealthLabel("Project Member", 30, 144, 255)
			end

			--damir
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 112105070 then
				player_hero:SetCustomHealthLabel("Project Member", 18, 51, 0)
			end

			--nezz
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 294607899 then
				player_hero:SetCustomHealthLabel("SW Legend", 30, 144, 255)
			end

			--lightforce
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 87707161 then
				player_hero:SetCustomHealthLabel("Map Creator", 255, 255, 255)
			end

			--bonusses
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 240969051 then
				player_hero:SetCustomHealthLabel("Project Member",  30, 144, 255)
			end
		
			--kuru
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 253439703 then
				player_hero:SetCustomHealthLabel("Mother of NWR",  250, 0, 142)
			end

			--zeni
			if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 35436742 then
				player_hero:SetCustomHealthLabel("Peace",  30, 144, 255)
			end
		end
	end
end
