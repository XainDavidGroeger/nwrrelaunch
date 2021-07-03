sai_god_drawings_bash= sai_god_drawings_bash or class({})
LinkLuaModifier( "modifier_god_drawings_bash",
				"heroes/sai/sai_god_drawings_bash.lua",
				 LUA_MODIFIER_MOTION_NONE )
--passive
function sai_god_drawings_bash:GetIntrinsicModifierName() return 
	"modifier_god_drawings_bash"
end
--init check
function sai_god_drawings_bash:Spawn() if not IsServer() then return end end

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
	local filter = UnitFilter(
		params.target,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self.parent:GetTeamNumber()
	)
	if filter~=UF_SUCCESS then return end
	if not RollPseudoRandomPercentage( self.chance, self.pseudoseed, self.parent ) then return end
	-- procDabash
	self:ApplyDaBash( params.target )
end
--helper
function modifier_god_drawings_bash:ApplyDaBash(target)
	target:AddNewModifier(self.parent, self.ability, 
						"modifier_stunned", 
						{duration = self.stun_duration})

	-- set cooldown
	self.ability:UseResources( false, false, true )
	local damage = self.bonus_damage + self:GetAbility():GetCaster():GetAttackDamage()
	-- apply damage
	ApplyDamage({victim = target,
		ability = self.ability,
		attacker = self.parent,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL})
	--TODO LF crit dmg output cosa esto es?
	PopupDamage(target, damage)
	--TODO play effects
	target:EmitSound("sakura_strength_impact")
end