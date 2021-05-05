-- Original Credits: Path of Guardians

--[[ Available triggers:
* OnMoveOrder
* OnAttackOrder
* OnBuyback
* OnDeath
* OnSpawn
* OnFirstSpawn
* OnTakeDamage
* OnHeroKill
* OnCreepKill
* OnCreepDeny
* OnAbilityCast
* OnArcaneRune
* OnDoubleDamageRune
* OnBountyRune
* OnHasteRune
* OnIllusionRune
* OnInvisibilityRune
* OnRegenRune
* OnFirstBlood
* OnItemPurchased
* OnItemPickup
* OnVictory
* OnDefeat
]]

local VO_DEFAULT_COOLDOWN = 6

LinkLuaModifier("modifier_responses", "scripts/vscripts/modifiers/modifier_responses.lua", LUA_MODIFIER_MOTION_NONE)
if VoiceResponses == nil then
	VoiceResponses = class({})
end

function VoiceResponses:Start()
	if not VoiceResponses.started then
		VoiceResponses.started = true
	end

	VoiceResponses.responses = {}

	-- Create dummy with response modifier to hook to events
	local dummy = CreateUnitByName('npc_dota_thinker', Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS)
	local modifier = dummy:AddNewModifier(nil, nil, "modifier_responses", {})

	-- Hook up event handler
	modifier.FireOutput = function(outputName, data) self:FireOutput(outputName, data) end

	-- Listen for unit spawns
	ListenToGameEvent("npc_spawned", function(context, event) self:FireOutput('OnUnitSpawn', event) end, self)
	ListenToGameEvent("dota_player_gained_level", function(context, event) self:FireOutput('OnHeroLevelUp', event) end, self)
	ListenToGameEvent("dota_rune_activated_server", function(context, event) self:FireOutput('OnRunePickup', event) end, self)
	ListenToGameEvent("dota_item_purchased", function(context, event) self:FireOutput('OnItemPurchased', event) end, self)
	ListenToGameEvent("dota_item_picked_up", function(context, event) self:FireOutput('OnItemPickup', event) end, self)
	ListenToGameEvent("game_rules_state_change", function(context, event) self:FireOutput('OnGameRulesStateChange', event) end, self)  
end

-- Wrap events in dynamic_wraps
function VoiceResponses:FireOutput(outputName, data)
	if VoiceResponses[outputName] ~= nil then
		Dynamic_Wrap(VoiceResponses, outputName)(self, data)
	end
end

function VoiceResponses:RegisterUnit(unitName, configFile)
	-- Load unit config
	VoiceResponses.responses[unitName] = LoadKeyValues(configFile)
end

function VoiceResponses:PlayTrigger(responses, response_rules, unit)
	local lastCast = response_rules.lastCast or 0
	local cooldown = response_rules.Cooldown or VO_DEFAULT_COOLDOWN
	local allChat = response_rules.AllChat or false
	local delay = response_rules.Delay or 0

	-- Priority 0 = follows default cooldown (move & attack)
	-- Priority 1 = follows priority cooldown (abilities, taking damage)
	-- Priority 2 = always triggers (runes, kills/death/respawn, victory/defeat)
	local priority = response_rules.Priority or 0

	--Prevents overlap
	local priorityCooldown = 1.5 + delay

	local lastSound = responses.lastSound or 0
	local lastCooldown = responses.Cooldown or 0 

	local global = true
	if response_rules.Global ~= nil then
		global = response_rules.Global
	end

	if response_rules.Sounds == nil then return end

	-- Check cooldown
	local gameTime = GameRules:GetGameTime()
	if gameTime - lastSound < lastCooldown and priority == 0 then
		return
	end

	if gameTime - lastSound < priorityCooldown and priority < 2 then
		return
	end

	if gameTime - lastCast < cooldown then
		return
	end

	responses.lastSound = gameTime
	if cooldown > VO_DEFAULT_COOLDOWN then
		responses.Cooldown = VO_DEFAULT_COOLDOWN
	else
		responses.Cooldown = cooldown
	end
	response_rules.lastCast = gameTime

	-- Get total weight of sounds
	local total_weight = response_rules.total_weight
	if total_weight == nil then
		response_rules.total_weight = 0
		for sound, weight in pairs(response_rules.Sounds) do
			response_rules.total_weight = response_rules.total_weight + weight
		end
		total_weight = response_rules.total_weight
	end

	-- Selected a sound by weight
	local selection = RandomInt(1, total_weight)
	local count = 0
	for soundName, weight in pairs(response_rules.Sounds) do
		count = count + weight
		if count >= selection then
			return Timers:CreateTimer(delay, function () self:PlaySound(soundName, unit, allChat, global) end)
		end
	end
end

function VoiceResponses:TriggerSound(triggerName, unit, responses)
	local response_rules = responses[triggerName]

	if response_rules ~= nil then
		self:PlayTrigger(responses, response_rules, unit)
	end
end

function VoiceResponses:TriggerSoundSpecial(triggerName, special, unit, responses)
	local response_rules = responses[triggerName]

	if response_rules ~= nil then
		if response_rules[special] then
			self:PlayTrigger(responses, response_rules[special], unit)
		end
	end
end

function VoiceResponses:PlaySound(soundName, unit, allChat, global)
	if not IsServer() then return end

	print(soundName)

	if allChat then
		unit:EmitSound(soundName)
	else
		local playerID = unit:GetPlayerOwnerID()
		local player = PlayerResource:GetPlayer(playerID)
		if playerID >= 0 and player then
			EmitSoundOnEntityForPlayer(soundName, unit, playerID)
		end
	end
end
--================================================================================
-- EVENT HANDLERS
--================================================================================
function VoiceResponses:OnOrder(order)
	local unitResponses = VoiceResponses.responses[order.unit:GetUnitName()]
	if unitResponses ~= nil then
		-- Move order
		if order.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION
		  or order.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET
		  or order.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
			self:TriggerSound("OnMoveOrder", order.unit, unitResponses)
		end

		-- Attack order
		if order.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
			self:TriggerSound("OnAttackOrder", order.unit, unitResponses)
		end

		-- Buyback
		if order.order_type == DOTA_UNIT_ORDER_BUYBACK then
			self:TriggerSound("OnBuyback", order.unit, unitResponses)
		end
	end
end

function VoiceResponses:OnUnitDeath(event)
	-- Unit death
	local unitResponses = VoiceResponses.responses[event.unit:GetUnitName()]
	if unitResponses ~= nil and not event.unit:IsIllusion() then
		if event.unit:IsReincarnating() then 
			self:TriggerSound("OnReincarnate", event.unit, unitResponses)
		else
			self:TriggerSound("OnDeath", event.unit, unitResponses)
		end
	end

	-- Unit kill
	if event.attacker then
		unitResponses = VoiceResponses.responses[event.attacker:GetUnitName()]
		if unitResponses ~= nil then
			if event.unit:IsRealHero() then
				if GetTeamHeroKills(DOTA_TEAM_GOODGUYS) + GetTeamHeroKills(DOTA_TEAM_BADGUYS) == 1 then
					self:TriggerSound("OnFirstBlood", event.attacker, unitResponses)
				else
					self:TriggerSound("OnHeroKill", event.attacker, unitResponses)
				end
			else
				if event.unit:GetTeam() == event.attacker:GetTeam() then
					self:TriggerSound("OnCreepDeny", event.attacker, unitResponses)
				else
					self:TriggerSound("OnCreepKill", event.attacker, unitResponses)
				end
			end
		end
	end
end

function VoiceResponses:OnUnitSpawn(event)
	local unit = EntIndexToHScript(event.entindex)
	local unitResponses = VoiceResponses.responses[unit:GetUnitName()]

	if 						unit:GetName() == "npc_dota_hero_dragon_knight" 
						or  unit:GetName() == "npc_dota_hero_beastmaster" 
						or  unit:GetName() == "npc_dota_hero_antimage"
	then
		return nil
	end

	if unitResponses ~= nil and not unit:IsIllusion() then
		-- Check first spawn or not
		if unit._responseFirstSpawn then
			self:TriggerSound("OnSpawn", unit, unitResponses)
		else
			self:TriggerSound("OnFirstSpawn", unit, unitResponses)
			unit._responseFirstSpawn = true
		end
	end
end

function VoiceResponses:OnTakeDamage(event)
	local unitResponses = VoiceResponses.responses[event.unit:GetUnitName()]
	if unitResponses ~= nil and not event.unit:IsIllusion() then
		-- Only trigger on hero or tower damage
		local attacker = event.attacker
		if attacker and attacker ~= event.unit then
			if attacker:IsHero() or attacker:IsTower() then
				self:TriggerSound("OnTakeDamage", event.unit, unitResponses)
			end
		end
	end
end

function VoiceResponses:OnHeroLevelUp(event)

	local unit = EntIndexToHScript(event.hero_entindex)
	local unitResponses = VoiceResponses.responses[unit:GetUnitName()]

	if unitResponses ~= nil and not unit:IsIllusion() then
		self:TriggerSound("OnLevelUp", unit, unitResponses)
	end
end

function VoiceResponses:OnAbilityExecuted(event)
	local unitResponses = VoiceResponses.responses[event.unit:GetUnitName()]
	if unitResponses ~= nil then
		self:TriggerSoundSpecial("OnAbilityCast", event.ability:GetAbilityName(), event.unit, unitResponses)
	end
end

function VoiceResponses:OnRunePickup(event)
	local unit = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local unitResponses = VoiceResponses.responses[unit:GetUnitName()]
	if unitResponses then
		if event.rune == DOTA_RUNE_DOUBLEDAMAGE then
			self:TriggerSound("OnDoubleDamageRune", unit, unitResponses)
		elseif event.rune == DOTA_RUNE_HASTE then
			self:TriggerSound("OnHasteRune", unit, unitResponses)
		elseif event.rune == DOTA_RUNE_ILLUSION then
			self:TriggerSound("OnIllusionRune", unit, unitResponses)
		elseif event.rune == DOTA_RUNE_INVISIBILITY then
			self:TriggerSound("OnInvisibilityRune", unit, unitResponses)
		elseif event.rune == DOTA_RUNE_REGENERATION then
			self:TriggerSound("OnRegenRune", unit, unitResponses)
		elseif event.rune == DOTA_RUNE_BOUNTY then
			self:TriggerSound("OnBountyRune", unit, unitResponses)
		elseif event.rune == DOTA_RUNE_ARCANE  then
			self:TriggerSound("OnArcaneRune", unit, unitResponses)
		end
	end
end

function VoiceResponses:OnItemPurchased(event)
	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local unitResponses = VoiceResponses.responses[hero:GetUnitName()]
	if unitResponses then
		self:TriggerSoundSpecial("OnItemPurchased", event.itemname, hero, unitResponses)
	end
end


function VoiceResponses:OnItemPickup(event)
	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local item = EntIndexToHScript(event.ItemEntityIndex)
	local unitResponses = VoiceResponses.responses[hero:GetUnitName()]
	if unitResponses then
		if item:GetPurchaser() == hero then
			self:TriggerSoundSpecial("OnItemPickup", event.itemname, hero, unitResponses)
		end
	end
end

function VoiceResponses:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_POST_GAME then
		-- Figure out winner
		local winner = DOTA_TEAM_GOODGUYS
		local ancients = Entities:FindAllByClassname("npc_dota_fort")
		if ancients[1] then
			winner = ancients[1]:GetTeam()
		end

		-- Loop over heroes
		local heroes = HeroList:GetAllHeroes()
		for _, hero in pairs(heroes) do
			-- Check if unit has responses
			local responses = VoiceResponses.responses[hero:GetUnitName()]
			if responses then
				-- Figure out win or loss
				if hero:GetTeam() == winner then
					self:TriggerSound("OnVictory", hero, responses)
				else
					self:TriggerSound("OnDefeat", hero, responses)
				end
			end
		end
	end
end