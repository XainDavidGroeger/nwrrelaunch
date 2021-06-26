guy_seventh_gate_open = class({})
LinkLuaModifier( "modifier_guy_seventh_gate", "scripts/vscripts/heroes/guy/guy_seventh_gate_open.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guy_morning_peacock_buff", "scripts/vscripts/heroes/guy/guy_morning_peacock.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guy_morning_peacock_cd_reset", "scripts/vscripts/heroes/guy/guy_morning_peacock.lua", LUA_MODIFIER_MOTION_NONE )
 
function guy_seventh_gate_open:Precache(context)
	PrecacheResource("soundfile",  "soundevents/game_sounds_heroes/game_sounds_sven.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/heroes/guy/guy_open_gates_talking.vsndevts", context)
	PrecacheResource("soundfile",  "soundevents/heroes/guy/guy_gates_cast.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/guy/wyvern_winters_curse_buff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/guy/gates_toggle_on.vpcf", context)
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
 
--  function guy_seventh_gate_open:OnSpellStart()
-- 	if IsServer() then
-- 		local caster 	= self:GetCaster();
-- 		local ability 	= self;
-- 		guy_seventh_gate_open:ToggleOn(caster, ability);
-- 	end
--  end
 
 function guy_seventh_gate_open:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_guy_seventh_gate", {})

	if not IsServer() then return end
	-- check sister ability
	local ability = caster:FindAbilityByName("guy_seventh_gate_close")
	if not ability then
		ability = caster:AddAbility( "guy_seventh_gate_close" )
		ability:SetStolen( true )
	end

	-- check ability level
	ability:SetLevel( self:GetLevel() )

	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)

	-- local whirwind_ability = caster:FindAbilityByName( "guy_leaf_strong_whirlwind" )
	-- if whirwind_ability then
	-- 	whirwind_ability.texture_name = "guy_dynamic_entry_gates"
	-- end

	-- if IsServer() then 
	-- 	local toggle 	= self:GetToggleState();
	-- 	local caster 	= self:GetCaster();
	-- 	local ability 	= self;
	-- 	self.caster = caster
	-- 	--self.ability = self

	-- 	if toggle == true then 
	-- 		guy_seventh_gate_open:ToggleOn(caster, ability);
	-- 	else 
	-- 		local ability2_name = self.caster:GetAbilityByIndex(1)
	-- 		local ability3_name = self.caster:GetAbilityByIndex(2)

	-- 		local ability1_cooldown = self.caster:GetAbilityByIndex(1):GetCooldownTimeRemaining()
	-- 		local ability1_level = self.caster:GetAbilityByIndex(1):GetLevel()
	-- 		self.caster:AddAbility("guy_leaf_strong_whirlwind")
	-- 		self.caster:SwapAbilities("guy_leaf_strong_whirlwind", "guy_leaf_strong_whirlwind_ult", true, false)
	-- 		self.caster:RemoveAbility("guy_leaf_strong_whirlwind_ult")
	-- 		self.caster:GetAbilityByIndex(1):SetLevel(ability1_level)
	-- 		self.caster:GetAbilityByIndex(1):StartCooldown(ability1_cooldown)

	-- 		if self.caster:HasAbility("guy_strong_fist_ult") then 
	-- 			ability_name = "guy_strong_fist_ult"
	-- 		end

	-- 		if self.caster:HasAbility("guy_morning_peacock") then 
	-- 			ability_name = "guy_morning_peacock"
	-- 		end

	-- 		local ability2_cooldown = self.caster:GetAbilityByIndex(2):GetCooldownTimeRemaining()
	-- 		local ability2_level = self.caster:GetAbilityByIndex(2):GetLevel()
	-- 		self.caster:AddAbility("guy_strong_fist")
	-- 		self.caster:SwapAbilities("guy_strong_fist", ability_name, true, false)
	-- 		self.caster:RemoveAbility(ability_name)
	-- 		self.caster:GetAbilityByIndex(2):SetLevel(ability2_level)
	-- 		self.caster:GetAbilityByIndex(2):StartCooldown(ability2_cooldown)
			
	-- 		caster:RemoveModifierByName("modifier_guy_seventh_gate")
	-- 		if caster:HasModifier("modifier_guy_morning_peacock_buff") then
	-- 		    caster:RemoveModifierByName("modifier_guy_morning_peacock_buff")
	-- 		    caster:RemoveModifierByName("modifier_guy_morning_peacock_cd_reset")
	-- 		end
	-- 	end
	-- end
end

-- function guy_seventh_gate_open:ToggleOn(caster, ability)
-- 	caster:AddNewModifier(caster, ability, "modifier_guy_seventh_gate", {});
-- 	ParticleManager:CreateParticle("particles/units/heroes/guy/gates_toggle_on.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
-- end

guy_seventh_gate_close = class({})

function guy_seventh_gate_close:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_guy_seventh_gate")
end

modifier_guy_seventh_gate = modifier_guy_seventh_gate or class({})

function modifier_guy_seventh_gate:IsHidden() return false end
function modifier_guy_seventh_gate:IsBuff() return true end
function modifier_guy_seventh_gate:IsPurgable() return false end
function modifier_guy_seventh_gate:RemoveOnDeath() return true end

function modifier_guy_seventh_gate:OnCreated()

	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	self.ms_bonus = self.ability:GetSpecialValueFor("ms_bonus") + self.caster:FindTalentValue("special_bonus_guy_3")
	self.attack_bonus = self.ability:GetSpecialValueFor("bonus_damage")
	self.base_attack_time = self.ability:GetSpecialValueFor("bat") + self.caster:FindTalentValue("special_bonus_guy_2")

	--sounds
	if not IsServer() then return end
	self.caster:EmitSound("guy_gates_cast")
	self.caster:EmitSound("guy_ulti_new")
	self.caster:EmitSound("guy_open_gates_talking")

	-- start interval for hp lose
	self:StartIntervalThink(0.1)
end

function modifier_guy_seventh_gate:OnRemoved()
	-- ParticleManager:DestroyParticle(self.pfx3, true)
	-- ParticleManager:ReleaseParticleIndex(self.pfx3)
	-- ParticleManager:DestroyParticle(self.pfx4, true)
	-- ParticleManager:ReleaseParticleIndex(self.pfx4)
end

function modifier_guy_seventh_gate:OnDestroy()
	local caster = self:GetAbility():GetCaster()
	local ability = caster:FindAbilityByName( "guy_seventh_gate_open" )
	
	if not IsServer() then return end
	caster:SwapAbilities(
		"guy_seventh_gate_open",
		"guy_seventh_gate_close",
		true,
		false
	)
end

function modifier_guy_seventh_gate:OnIntervalThink()
	local drain_hp_percent = self:GetAbility():GetSpecialValueFor("hp_drain")
	local drain_hp = (self.caster:GetMaxHealth() / 100) * drain_hp_percent * 0.1
	local damage_table = {
		victim = self.caster,
		attacker = self.caster,
		damage = drain_hp,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
		ability = self
	}
	print(damage_table.damage)
	print(damage_table.damage_type)
	print(damage_table.damage_flags)
	ApplyDamage(damage_table)
end

function modifier_guy_seventh_gate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
end

function modifier_guy_seventh_gate:GetModifierMoveSpeedBonus_Constant()
	return self.ms_bonus
end

function modifier_guy_seventh_gate:GetModifierBaseAttackTimeConstant()
	return self.base_attack_time
end

function modifier_guy_seventh_gate:GetEffectName()
	return "particles/units/heroes/guy/guy_gates_generic_core.vpcf"
end

function modifier_guy_seventh_gate:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
