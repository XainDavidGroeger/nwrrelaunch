guy_seventh_gate_open = class({})
LinkLuaModifier( "modifier_guy_seventh_gate", "scripts/vscripts/heroes/guy/guy_seventh_gate_open.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guy_morning_peacock_buff", "scripts/vscripts/heroes/guy/guy_morning_peacock.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guy_morning_peacock_cd_reset", "scripts/vscripts/heroes/guy/guy_morning_peacock.lua", LUA_MODIFIER_MOTION_NONE )
 
function guy_seventh_gate_open:Precache(context)
	PrecacheResource("soundfile",  "soundevents/game_sounds_heroes/game_sounds_sven.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/heroes/guy/guy_open_gates_talking.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/heroes/guy/guy_gates_cast.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/guy/wyvern_winters_curse_buff.vpcf", context)
end

 function guy_seventh_gate_open:GetBehavior()
	 return self.BaseClass.GetBehavior(self)
 end
 
 function guy_seventh_gate_open:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
 end
 
 function guy_seventh_gate_open:ProcsMagicStick()
    return true
end
 
 function guy_seventh_gate_open:OnSpellStart()
	if IsServer() then
		local caster 	= self:GetCaster();
		local ability 	= self;
		guy_seventh_gate_open:ToggleOn(caster, ability);
	end
 end
 
 function guy_seventh_gate_open:OnToggle()
	if IsServer() then 
		local toggle 	= self:GetToggleState();
		local caster 	= self:GetCaster();
		local ability 	= self;
		self.caster = caster
		--self.ability = self

		if toggle == true then 
			guy_seventh_gate_open:ToggleOn(caster, ability);
		else 
			local ability2_name = self.caster:GetAbilityByIndex(1)
			local ability3_name = self.caster:GetAbilityByIndex(2)

			local ability1_cooldown = self.caster:GetAbilityByIndex(1):GetCooldownTimeRemaining()
			local ability1_level = self.caster:GetAbilityByIndex(1):GetLevel()
			self.caster:AddAbility("guy_leaf_strong_whirlwind")
			self.caster:SwapAbilities("guy_leaf_strong_whirlwind", "guy_leaf_strong_whirlwind_ult", true, false)
			self.caster:RemoveAbility("guy_leaf_strong_whirlwind_ult")
			self.caster:GetAbilityByIndex(1):SetLevel(ability1_level)
			self.caster:GetAbilityByIndex(1):StartCooldown(ability1_cooldown)

			if self.caster:HasAbility("guy_strong_fist_ult") then 
				ability_name = "guy_strong_fist_ult"
			end

			if self.caster:HasAbility("guy_morning_peacock") then 
				ability_name = "guy_morning_peacock"
			end

			local ability2_cooldown = self.caster:GetAbilityByIndex(2):GetCooldownTimeRemaining()
			local ability2_level = self.caster:GetAbilityByIndex(2):GetLevel()
			self.caster:AddAbility("guy_strong_fist")
			self.caster:SwapAbilities("guy_strong_fist", ability_name, true, false)
			self.caster:RemoveAbility(ability_name)
			self.caster:GetAbilityByIndex(2):SetLevel(ability2_level)
			self.caster:GetAbilityByIndex(2):StartCooldown(ability2_cooldown)
			
			caster:RemoveModifierByName("modifier_guy_seventh_gate")
			if caster:HasModifier("modifier_guy_morning_peacock_buff") then
			    caster:RemoveModifierByName("modifier_guy_morning_peacock_buff")
			    caster:RemoveModifierByName("modifier_guy_morning_peacock_cd_reset")
			end
		end
	end
end

function guy_seventh_gate_open:ToggleOn(caster, ability)
	caster:AddNewModifier(caster, ability, "modifier_guy_seventh_gate", {});
end

modifier_guy_seventh_gate = modifier_guy_seventh_gate or class({})

function modifier_guy_seventh_gate:IsHidden() return false end
function modifier_guy_seventh_gate:IsBuff() return true end

function modifier_guy_seventh_gate:OnCreated()

	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	self.ms_bonus = self.ability:GetSpecialValueFor("ms_bonus") + self.caster:FindTalentValue("special_bonus_guy_3")
	self.attack_bonus = self.ability:GetSpecialValueFor("bonus_damage")
	self.base_attack_time = self.ability:GetSpecialValueFor("bat") + self.caster:FindTalentValue("special_bonus_guy_2")
	--print(self.base_attack_time)

	self.pfx3 = ParticleManager:CreateParticle("particles/units/heroes/guy/wyvern_winters_curse_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( self.pfx3, 0, self:GetCaster(), PATTACH_POINT, "attach_origin", self:GetCaster():GetAbsOrigin(), false )
	self.pfx4 = ParticleManager:CreateParticle( "particles/units/heroes/guy/wyvern_winters_curse_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( self.pfx4, 0, self:GetCaster(), PATTACH_POINT, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false )

	--sounds
	self.caster:EmitSound("guy_gates_cast")
	self.caster:EmitSound("guy_ulti_new")
	self.caster:EmitSound("guy_open_gates_talking")

	--change abilities
	
	local ability1_level = self.caster:GetAbilityByIndex(1):GetLevel()
	local ability1_cooldown = self.caster:GetAbilityByIndex(1):GetCooldownTimeRemaining()
	self.caster:AddAbility("guy_leaf_strong_whirlwind_ult")
	self.caster:SwapAbilities("guy_leaf_strong_whirlwind", "guy_leaf_strong_whirlwind_ult", false, true)
	self.caster:RemoveAbility("guy_leaf_strong_whirlwind")
	self.caster:GetAbilityByIndex(1):SetLevel(ability1_level)
	self.caster:GetAbilityByIndex(1):StartCooldown(ability1_cooldown)


	local ability_name = "guy_strong_fist_ult"
	local ability1 = self.caster:FindAbilityByName("special_bonus_guy_4")
	if ability1 ~= nil then
	    if ability1:IsTrained() then
	    	ability_name = "guy_morning_peacock"
	    end
	end
	local ability2_level = self.caster:GetAbilityByIndex(2):GetLevel()
	local ability2_cooldown = self.caster:GetAbilityByIndex(2):GetCooldownTimeRemaining()
	self.caster:AddAbility(ability_name)
	self.caster:SwapAbilities("guy_strong_fist", ability_name, false, true)
	self.caster:RemoveAbility("guy_strong_fist")
	self.caster:GetAbilityByIndex(2):SetLevel(ability2_level)
	self.caster:GetAbilityByIndex(2):StartCooldown(ability2_cooldown)

	-- start interval for hp lose
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_guy_seventh_gate:OnRemoved()
	ParticleManager:DestroyParticle(self.pfx3, true)
	ParticleManager:ReleaseParticleIndex(self.pfx3)
	ParticleManager:DestroyParticle(self.pfx4, true)
	ParticleManager:ReleaseParticleIndex(self.pfx4)
end

function modifier_guy_seventh_gate:OnIntervalThink()
	local drain_hp_percent = self:GetAbility():GetSpecialValueFor("hp_drain")
	drain_hp_percent = drain_hp_percent / 10
	local drain_hp = (self.caster:GetMaxHealth() / 100) * drain_hp_percent
	if self.caster:GetHealth() - drain_hp > 0 then
		self.caster:SetHealth(self.caster:GetHealth() - drain_hp)
	else
		self:GetAbility():ToggleAbility()
	end	
end

function modifier_guy_seventh_gate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_guy_seventh_gate:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

function modifier_guy_seventh_gate:GetModifierPreAttack_BonusDamage()
	return self.attack_bonus
end

function modifier_guy_seventh_gate:GetMinHealth()
	return 1
end

function modifier_guy_seventh_gate:GetModifierBaseAttackTimeConstant()
	return self.base_attack_time
end
