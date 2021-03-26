function GameMode:RescaleUnit( unit )
	if     unit:GetName() == "npc_dota_roshan" then 
		GameMode:kyuubi(unit)
    elseif  unit:GetName() == "npc_dota_courier" then 
    	GameMode:rescaleCourier(unit)
    elseif  unit:GetModelName() == "models/heroes/clinkz/clinkz_arrow.vmdl" then 
        unit:SetModelScale(0.6)
    else                 
    	
    end
end

function GameMode:kyuubi( unit )
	unit:SetModelScale(3.6)
end


function GameMode:rescaleCourier( unit )
	if unit:GetModelName() == "models/props_gameplay/donkey.vmdl" then
		unit:SetModelScale(0.6)
	end
	if unit:GetModelName() == "models/props_gameplay/donkey_dire.vmdl" then
		unit:SetModelScale(0.6)
	end
end


function GameMode:ChangeBuildings( keys)
    local hokageBuilding = Entities:FindByModel(nil, "models/props_structures/radiant_ancient001.vmdl")
    hokageBuilding:SetModelScale(0.55)
    local akatBase = Entities:FindByModel(nil, "models/props_structures/dire_ancient_base001.vmdl")
    akatBase:SetModelScale(0.55) 

    --alliance towers
    local allianceTower = Entities:FindByModel(nil, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)

     --akatsuki towers
    local akatTower = Entities:FindByModel(nil, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)

    --alliance melee rax
    local melee_raxs = Entities:FindByModel(nil, "models/props_structures/radiant_melee_barracks001.vmdl")
    melee_raxs:SetModelScale(1.4)
    local melee_raxs = Entities:FindByModel(melee_raxs, "models/props_structures/radiant_melee_barracks001.vmdl")
    melee_raxs:SetModelScale(1.4)
    local melee_raxs = Entities:FindByModel(melee_raxs, "models/props_structures/radiant_melee_barracks001.vmdl")
    melee_raxs:SetModelScale(1.4)

    --akat ranged rax
    local akat_melee_raxs = Entities:FindByModel(nil, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(1.4)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(1.4)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(1.4)

    --akat melee rax
    local akat_melee_raxs = Entities:FindByModel(nil, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(0.75)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(0.75)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(0.75)

    --alliance ranged rax
    local range_raxs = Entities:FindByModel(nil, "models/props_structures/radiant_ranged_barracks001.vmdl")
    range_raxs:SetModelScale(0.8)
    local range_raxs = Entities:FindByModel(range_raxs, "models/props_structures/radiant_ranged_barracks001.vmdl")
    range_raxs:SetModelScale(0.8)
    local range_raxs = Entities:FindByModel(range_raxs, "models/props_structures/radiant_ranged_barracks001.vmdl")
    range_raxs:SetModelScale(0.8)

    --alliance statue 1 alt towers
    local statue_1 = Entities:FindByModel(nil, "models/props_structures/radiant_statue001.vmdl")
    statue_1:SetModelScale(2.0)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/radiant_statue001.vmdl")
    statue_1:SetModelScale(2.0)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/radiant_statue001.vmdl")
    statue_1:SetModelScale(2.0)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/radiant_statue001.vmdl")
    statue_1:SetModelScale(2.0)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/radiant_statue001.vmdl")
    statue_1:SetModelScale(2.0)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/radiant_statue001.vmdl")
    statue_1:SetModelScale(2.0)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/radiant_statue001.vmdl")
    statue_1:SetModelScale(2.0)
    


    --akat statue
    local statue_1 = Entities:FindByModel(nil, "models/props_structures/dire_column001.vmdl")
    statue_1:SetModelScale(1.5)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/dire_column001.vmdl")
    statue_1:SetModelScale(1.5)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/dire_column001.vmdl")
    statue_1:SetModelScale(1.5)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/dire_column001.vmdl")
    statue_1:SetModelScale(1.5)
    local statue_1 = Entities:FindByModel(statue_1, "models/props_structures/dire_column001.vmdl")
    statue_1:SetModelScale(1.5)


end