-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')
require('libraries/popups')
require('libraries/utils')
require('libraries/animations')


function Precache( context )
--[[
	This function is used to precache resources/units/items/abilities that will be needed
	for sure in your game and that will not be precached by hero selection.  When a hero
	is selected from the hero selection screen, the game will precache that hero's assets,
	any equipped cosmetics, and perform the data-driven precaching defined in that hero's
	precache{} block, as well as the precache{} block for any equipped abilities.

	See GameMode:PostLoadPrecache() in gamemode.lua for more information
	]]


	DebugPrint("[BAREBONES] Performing pre-load precache")

	-- Particles can be precached individually or by folder
	-- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
	--PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
	--PrecacheResource("particle_folder", "particles/test_particle", context)

	-- Sounds can precached here like anything else
	PrecacheResource("soundfile", "soundevents/hero_pick.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/loading_screen.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/itachi_crows.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/itachi_amateratsu.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/itachi_amateratsu_burning.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/naruto_rasen_shuriken.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/naruto_kills_sasuke.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/sasuke_kills_naruto.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/sasuke_kills_gaara.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/sasuke_kills_itachi.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/madara_trees.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/kakashi_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/haku_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/hidan_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/zabuza_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/madara_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/kisame_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/gaara_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/yondaime_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/naruto_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/neji_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/guy_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/onoki_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/raikage_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/sakura_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/sasuke_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/kankuro_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/shikamaru_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/temari_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/heroes/anko_soundevents.vsndevts", context)       
	PrecacheResource("soundfile", "soundevents/heroes/itachi_soundevents.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/global/akat_start.vsndevts", context)        
	PrecacheResource("soundfile", "soundevents/global/shinobi_start.vsndevts", context)      
	PrecacheResource("soundfile", "soundevents/global/malulubul.vsndevts", context)      
	PrecacheResource("soundfile", "soundevents/clones/clone_pop.vsndevts", context)      
		

	-- Entire items can be precached by name
	-- Abilities can also be precached in this way despite the name

	--PrecacheItemByNameSync("item_example_item", context)

	-- Models
	PrecacheModel("models/gaara/gaara.vmdl", context)

	-- Stuff
	PrecacheResource("particle_folder", "particles/hero", context)
	PrecacheResource("particle_folder", "particles/units", context)
	PrecacheResource("particle_folder", "particles/ambient", context)
	PrecacheResource("particle_folder", "particles/generic_gameplay", context)
	PrecacheResource("particle_folder", "particles/status_fx/", context)
	PrecacheResource("particle_folder", "particles/item", context)
	PrecacheResource("particle_folder", "particles/items_fx", context)
	PrecacheResource("particle_folder", "particles/items2_fx", context)
	PrecacheResource("particle_folder", "particles/items3_fx", context)

	LinkLuaModifier("modifier_custom_mechanics", "modifiers/modifier_custom_mechanics", LUA_MODIFIER_MOTION_NONE)
end

-- Create the game mode when we activate
function Activate()
	--loading custom key values
	GameRules.heroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt") 
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
end