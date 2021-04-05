require('timers')

function sasuke_susanoo(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability0_level = caster:FindAbilityByName("sasuke_chidori_nagashi"):GetLevel()
	ability0_cooldown = caster:FindAbilityByName("sasuke_chidori_nagashi"):GetCooldownTimeRemaining()
	caster:AddAbility("Amaterasu")
	caster:SwapAbilities("sasuke_chidori_nagashi", "Amaterasu", false, true)
	caster:FindAbilityByName("Amaterasu"):SetLevel(ability0_level)
	caster:FindAbilityByName("Amaterasu"):StartCooldown(ability0_cooldown)
	
	ability1_level = caster:FindAbilityByName("sasuke_chidori_eiso"):GetLevel()
	ability1_cooldown = caster:FindAbilityByName("sasuke_chidori_eiso"):GetCooldownTimeRemaining()
	caster:AddAbility("sasunoo_arrow")
	caster:SwapAbilities("sasuke_chidori_eiso", "sasunoo_arrow", false, true)
	caster:FindAbilityByName("sasunoo_arrow"):SetLevel(ability1_level)
	caster:FindAbilityByName("sasunoo_arrow"):StartCooldown(ability1_cooldown)
	
	caster:SetModel("models/suka/sasuke_susanoo.vmdl")
	caster:SetOriginalModel("models/suka/sasuke_susanoo.vmdl")
	caster:SetModelScale(0.60)
end

function sasuke_susanoo_end(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability0_name = caster:GetAbilityByIndex(0)
	local ability1_name = caster:GetAbilityByIndex(1)
	
	ability0_level = caster:FindAbilityByName("Amaterasu"):GetLevel()
	ability0_cooldown = caster:FindAbilityByName("Amaterasu"):GetCooldownTimeRemaining()
	--caster:AddAbility("sasuke_chidori_nagashi")
	caster:SwapAbilities("Amaterasu", "sasuke_chidori_nagashi", false, true)
	caster:RemoveAbility("Amaterasu")
	caster:FindAbilityByName("sasuke_chidori_nagashi"):SetLevel(ability0_level)
	caster:FindAbilityByName("sasuke_chidori_nagashi"):StartCooldown(ability0_cooldown)

	ability1_cooldown = caster:FindAbilityByName("sasunoo_arrow"):GetCooldownTimeRemaining()
	ability1_level = caster:FindAbilityByName("sasunoo_arrow"):GetLevel()
	--caster:AddAbility("sasuke_chidori_eiso")
	caster:SwapAbilities("sasunoo_arrow", "sasuke_chidori_eiso", false, true)
	caster:RemoveAbility("sasunoo_arrow")
	caster:FindAbilityByName("sasuke_chidori_eiso"):SetLevel(ability1_level)
	caster:FindAbilityByName("sasuke_chidori_eiso"):StartCooldown(ability1_cooldown)

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
	
	if caster:GetUnitName() == "npc_dota_hero_kakashi" then
	caster:SetModel("models/kakashi/kaka.vmdl")
	caster:SetOriginalModel("models/kakashi/kaka.vmdl")
	caster:SetModelScale(0.82)
	else
	caster:SetModel("models/heroes/zuus/zuozhu.vmdl")
	caster:SetOriginalModel("models/heroes/zuus/zuozhu.vmdl")
	caster:SetModelScale(0.80)
	end
end