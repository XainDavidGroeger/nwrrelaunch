kisame_mizu_bunshin_no_jutsu = kisame_mizu_bunshin_no_jutsu or class({})

LinkLuaModifier("modifier_water_bunshin_bonus_damage", "scripts/vscripts/heroes/kisame/modifiers/modifier_water_bunshin_bonus_damage.lua", LUA_MODIFIER_MOTION_NONE)

function kisame_mizu_bunshin_no_jutsu:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function kisame_mizu_bunshin_no_jutsu:GetCastRange(location, target)
	return self:GetSpecialValueFor("range")
end

function kisame_mizu_bunshin_no_jutsu:ProcsMagicStick()
	return true
end

function kisame_mizu_bunshin_no_jutsu:OnSpellStart()
    local caster = self:GetCaster()
	local player = caster:GetPlayerID()
    local duration = self:GetSpecialValueFor("illusion_duration")
	local damage_percentage = self:GetSpecialValueFor("damage_percentage")
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local illusion_max_hp_percentage = self:GetSpecialValueFor("illusion_max_hp_percentage")
	local ability2 = caster:FindAbilityByName("special_bonus_kisame_2")
    if ability2 ~= nil then
  	 if ability2:IsTrained() then
  	 	illusion_max_hp_percentage = illusion_max_hp_percentage + 10.0
  	  end
    end
	
	EmitSoundOn("kisame_clone_cast", caster)
	EmitSoundOn("Hero_NagaSiren.MirrorImage", caster)
	
    caster:Stop()
    
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- Origin
	
	Timers:CreateTimer(0.2, function ()
	    ParticleManager:DestroyParticle(particle, true)
	    ParticleManager:ReleaseParticleIndex(particle)
	end)
	
	-- handle_UnitOwner needs to be nil, else it will crash the game.
    local illusion = CreateUnitByName("kisame_bunshin", origin, true, caster, nil, caster:GetTeamNumber())
    local illusion2 = CreateUnitByName("kisame_bunshin", origin, true, caster, nil, caster:GetTeamNumber())
	
	print(self.bunshin)
	if self.bunshin ~= nil then
	    self.bunshin:ForceKill(false)
	    self.bunshin2:ForceKill(false)
        EmitSoundOn("bunshin_death", self.bunshin)
        EmitSoundOn("bunshin_death", self.bunshin2)
          
        Timers:CreateTimer(0.1, function()
            self.bunshin:Destroy()
            self.bunshin2:Destroy()
        end)
	end
	
	illusion:SetControllableByPlayer(player, true)
	illusion2:SetControllableByPlayer(player, true)
    illusion:SetOwner(caster)
    illusion2:SetOwner(caster)
	
	--if kisame has his ulti activated, his bunshin should turn into the shark model and have the water prison modifier
    if caster:HasModifier("modifier_kisame_metamorphosis") then 
       illusion:SetOriginalModel("models/kisame_shark/kisame_shark.vmdl")
       illusion2:SetOriginalModel("models/kisame_shark/kisame_shark.vmdl")
  	   illusion:SetModelScale(1.0)
  	   illusion2:SetModelScale(1.0)
    end
	
	if caster:GetName() == "npc_dota_hero_kakashi" then
    	illusion:SetOriginalModel("models/kakashi_hd/kaka_hd_test.vmdl")
    	illusion2:SetOriginalModel("models/kakashi_hd/kaka_hd_test.vmdl")
    	illusion:SetModelScale(1.03)
    	illusion2:SetModelScale(1.03)
    end
	
	-- Set the unit as an illusion
    -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_water_bunshin_bonus_damage", -- modifier name
        { duration = duration } -- kv
    )
	illusion2:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_water_bunshin_bonus_damage", -- modifier name
        { duration = duration } -- kv
    )
	
	GameMode:RemoveWearables(illusion)
	GameMode:RemoveWearables(illusion2)

    illusion:SetForwardVector(caster:GetForwardVector())
    illusion2:SetForwardVector(caster:GetForwardVector())
	-- add water prison (channeled hold) to bunshin
    local ability_water = illusion:FindAbilityByName("kisame_bunshin_water_prison")
    local ability_water2 = illusion2:FindAbilityByName("kisame_bunshin_water_prison")
    ability_water:SetAbilityIndex(0)
    ability_water2:SetAbilityIndex(0)
    ability_water:SetLevel(self:GetLevel())
    ability_water2:SetLevel(self:GetLevel())
	
	-- add samehada passive to bunshin
    local ability_samehada = illusion:FindAbilityByName("kisame_samehada_bunshin")
    local ability_samehada2 = illusion2:FindAbilityByName("kisame_samehada_bunshin")
    ability_samehada:SetAbilityIndex(1)
    ability_samehada2:SetAbilityIndex(1)
    ability_samehada:SetLevel(self:GetLevel())
    ability_samehada2:SetLevel(self:GetLevel())
	
	illusion:SetMaxHealth(caster:GetMaxHealth() / 100 * illusion_max_hp_percentage)
	illusion2:SetMaxHealth(caster:GetMaxHealth() / 100 * illusion_max_hp_percentage)
	local hp_caster_percentage = caster:GetHealth() / (caster:GetMaxHealth() / 100)
    illusion:SetHealth(illusion:GetMaxHealth() / 100 * hp_caster_percentage)
    illusion2:SetHealth(illusion2:GetMaxHealth() / 100 * hp_caster_percentage)
    
    illusion:SetBaseDamageMin(caster:GetBaseDamageMin() / 100 * damage_percentage)
    illusion2:SetBaseDamageMin(caster:GetBaseDamageMin() / 100 * damage_percentage)
    illusion:SetBaseDamageMax(caster:GetBaseDamageMax() / 100 * damage_percentage)
    illusion2:SetBaseDamageMax(caster:GetBaseDamageMax() / 100 * damage_percentage)
	--local bonus_damage_preattack = caster:GetBonusDamageFromPrimaryStat() / 100 * damage_percentage
    --caster:SetModifierStackCount( "modifier_water_bunshin_bonus_damage", ability, bonus_damage_preattack)
	
	Timers:CreateTimer(duration, function ()
	    if illusion ~= nil then
	        illusion:ForceKill(false)
	        illusion2:ForceKill(false)
            EmitSoundOn("bunshin_death", illusion)
            EmitSoundOn("bunshin_death", illusion2)
              
            Timers:CreateTimer(0.1, function()
                illusion:Destroy()
                illusion2:Destroy()
            end)
		end
	end)
	
	Timers:CreateTimer(0.2, function ()
	    self.bunshin = illusion
        self.bunshin2 = illusion2
	end)
end

--[[function draw( keys )
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
end]]
