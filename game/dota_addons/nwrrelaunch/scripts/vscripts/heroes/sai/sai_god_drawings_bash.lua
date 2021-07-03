sai_god_drawings_bash= sai_god_drawings_bash or class({})
LinkLuaModifier( "modifier_god_drawings_bash",
				"heroes/sai/sai_god_drawings_bash.lua",
				 LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "modifier_generic_arc_lua",
--				 "lua_abilities/generic/modifier_generic_arc_lua",
--				  LUA_MODIFIER_MOTION_BOTH )
--LinkLuaModifier( "modifier_generic_stunned_lua",
--				 "lua_abilities/generic/modifier_generic_stunned_lua",
--				  LUA_MODIFIER_MOTION_NONE )
--passive
function sai_god_drawings_bash:GetIntrinsicModifierName() return 
	"modifier_god_drawings_bash"
end
--init
function sai_god_drawings_bash:Spawn()
	if not IsServer() then return end
end

modifier_god_drawings_bash= modifier_god_drawings_bash or class({})

function modifier_god_drawings_bash:IsHidden() return true end
function modifier_god_drawings_bash:IsDebuff() return false end
function modifier_god_drawings_bash:IsPurgable() return false end

function modifier_god_drawings_bash:OnRefresh( kv )
	self:OnCreated( kv )	
end
function modifier_god_drawings_bash:OnRemoved() end
function modifier_god_drawings_bash:OnDestroy() end

--inittialization
function modifier_god_drawings_bash:DeclareFunctions() return {
	MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
} end

function modifier_god_drawings_bash:OnCreated()
	if not IsServer() then return end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.pseudoseed = RandomInt( 1, 100 )

	-- references
	self.chance = self:GetAbility():GetSpecialValueFor( "bash_chance" )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	print( "caster:" )
	print( self:GetAbility():GetCaster():GetAttackDamage())
end

function modifier_god_drawings_bash:GetModifierProcAttack_Feedback( params )
	--checks
	if not IsServer() then return end
	if self.parent:PassivesDisabled() then return end
	if not self.ability:IsFullyCastable() then return end
	--if not self.ability:IsCooldownReady() then return end


	-- unit filter
	local filter = UnitFilter(
		params.target,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self.parent:GetTeamNumber()
	)
	if filter~=UF_SUCCESS then return end
	-- roll pseudo random
--[[ dark pro solution
if RollPercentage(random_per) then
	self:PlayEffects(params.attacker)
	params.attacker:AddNewModifier(parent, self, "modifier_stunned", {duration = stun_duration})
	ApplyDamage({ victim = params.attacker, attacker = parent, damage = damage, damage_type = damage_type })
end
]]
	if not RollPseudoRandomPercentage( self.chance, self.pseudoseed, self.parent ) then return end
	-- procDabash
	self:ApplyDaBash( params.target )
	-- set cooldown
	self.ability:UseResources( false, false, true )
end
--helper
function modifier_god_drawings_bash:ApplyDaBash(target)
--[[ create arc
	target:AddNewModifier(
		self.parent, -- player source
		self.ability, -- ability source
		"modifier_generic_arc_lua", -- modifier name
		{
			dir_x = direction.x,
			dir_y = direction.y,
			duration = self.knockback_duration,
			distance = dist,
			height = self.knockback_height,
			activity = ACT_DOTA_FLAIL,
		} -- kv
	)
]]
--[[stun1
	target:AddNewModifier(
		self.parent, -- player source
		self.ability, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = self.duration } -- kv
	)
]] 
-- stun2
	target:AddNewModifier(self.parent, self.ability, 
						"modifier_stunned", 
						{duration = self.stun_duration})

	--TODO calculate damage base+  bonus
	local damage = self.bonus_damage + self:GetAbility():GetCaster():GetAttackDamage()

	-- apply damage
	local damageTable = {
		victim = target,
		attacker = self.parent,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability, --Optional.
	}
	--[[
ApplyDamage({attacker = self.parent, 
			victim = target, 
			ability = self.ability, 
			damage = self.damage, 
			damage_type = DAMAGE_TYPE_PHYSICAL})
	]]
	ApplyDamage(damageTable)
	--TODO apply bonus damage
	--damageTable.damage = damage
	--ApplyDamage( damageTable )
	--TODO LF crit dmg output cosa esto es sangrado normal
	PopupDamage(target, damage)
	--TODO play effects
	--self:PlayEffects( target, target:IsCreep() )
	target:EmitSound("sakura_strength_impact")
end