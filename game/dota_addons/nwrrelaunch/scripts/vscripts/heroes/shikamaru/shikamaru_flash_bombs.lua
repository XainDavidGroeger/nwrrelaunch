shikamaru_flash_bombs = shikamaru_flash_bombs or class({})

LinkLuaModifier("modifier_flash_bomb_debuff", "scripts/vscripts/heroes/shikamaru/shikamaru_flash_bombs.lua", LUA_MODIFIER_MOTION_NONE)


function shikamaru_flash_bombs:GetAbilityTextureName()
	return "shikamaru_flash_bombs"
end
-------------------------------------------
function shikamaru_flash_bombs:GetAOERadius()
	return self:GetSpecialValueFor("spread_aoe") / 2
end

function shikamaru_flash_bombs:ProcsMagicStick()
    return true
end

function shikamaru_flash_bombs:ExplodeOnLocation(location)
	local vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", 
	PATTACH_ABSORIGIN, self.caster)
	ParticleManager:SetParticleControl(vfx, 0, location)
	ParticleManager:SetParticleControl(vfx, 1, Vector(0, 0, self.bomb_aoe))

	local targets = FindUnitsInRadius(
		self.caster:GetTeamNumber(), 
		location, 
		nil, 
		self.bomb_aoe, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	for _,target in pairs(targets) do

	ApplyDamage({
		victim = target,
		attacker = self.caster,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = nil,
	})

	-- TODO place explosion particle on target 

	-- add modifier
	target:AddNewModifier(self.caster, self, "modifier_flash_bomb_debuff", {duration = self.duration})
	end
end

function shikamaru_flash_bombs:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("shikamaru_flashbombs_cast")
	return true
end


function shikamaru_flash_bombs:OnSpellStart()

	local target_point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("spread_aoe")
	local posX = 0
	local posY = 0
	local r = radius / 2
	local small_radius = r / 2

	self.bomb_aoe = self:GetSpecialValueFor("bomb_aoe")
	self.damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_shikamaru_3")
	print(self.damage)
	self.duration = self:GetSpecialValueFor("debuff_duration")
	self.caster = self:GetCaster()

	self.outer_circle_positions = {}
	self.inner_circle_positions = {}

	self.pi_factor = 0.25
	self.small_pi_factor = 0.5

	for i = 1,8 do
		local bombX = target_point.x + r * math.cos(math.pi * self.pi_factor)
		local bombY = target_point.y + r * math.sin(math.pi * self.pi_factor)
		self.outer_circle_positions[i] = Vector(bombX, bombY, 0)
		self.pi_factor = self.pi_factor + 0.25
	end



	for i = 1,4 do
		local bombX = target_point.x + small_radius * math.cos(math.pi * self.small_pi_factor)
		local bombY = target_point.y + small_radius * math.sin(math.pi * self.small_pi_factor)
		self.inner_circle_positions[i] = Vector(bombX, bombY, 0)
		self.small_pi_factor = self.small_pi_factor + 0.5
	end

	for i = 1,8 do
		-- TODO place bomb particle
		--		CreateTempTree( self.outer_circle_positions[i], 5 )
	end

	for i = 1,4 do
		-- TODO place bomb particle
		--	CreateTempTree( self.inner_circle_positions[i], 5 )
	end
	

	Timers:CreateTimer( 0.1, function()
		for i = 1,8 do
			self:ExplodeOnLocation(self.outer_circle_positions[i])
		end

		for i = 1,4 do
			self:ExplodeOnLocation(self.inner_circle_positions[i])
		end
	end)

end


-- modifier

modifier_flash_bomb_debuff = class({})

-- Classifications
function modifier_flash_bomb_debuff:IsHidden()
	return false
end

function modifier_flash_bomb_debuff:IsDebuff()
	return true
end

function modifier_flash_bomb_debuff:IsStunDebuff()
	return false
end

function modifier_flash_bomb_debuff:IsPurgable()
	return true
end

-- Initializations
function modifier_flash_bomb_debuff:OnCreated( kv )
	-- references
	self.ms_slow = self:GetAbility():GetSpecialValueFor( "ms_slow" )
	self.miss_chance = self:GetAbility():GetSpecialValueFor( "miss_chance" )
end

function modifier_flash_bomb_debuff:OnRemoved()
end

function modifier_flash_bomb_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_flash_bomb_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
	}
	return funcs
end

function modifier_flash_bomb_debuff:GetModifierMiss_Percentage()
	return self.miss_chance
end

function modifier_flash_bomb_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

function modifier_flash_bomb_debuff:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]	= false
	}
end

function modifier_flash_bomb_debuff:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end


-- TODO add debuff particle