
--sai_super_god_drawing = sai_super_god_drawing or class({})
--LinkLuaModifier( "modifier_super_beast_drawing_debuff", "heroes/sai/sai_super_beast_drawing.lua" ,LUA_MODIFIER_MOTION_NONE )
sai_super_god_drawing = class({})
LinkLuaModifier( "modifier_sai_super_god_drawing_lua",
				"heroes/sai/sai_super_god_drawing.lua",
				 LUA_MODIFIER_MOTION_NONE )

function sai_super_god_drawing:GetAOERadius()
	return self:GetSpecialValueFor("area_of_effect")
end

function sai_super_god_drawing:IsHiddenWhenStolen()return true end
--------------------------------------------------------------------------------
--function sai_super_god_drawing:OnAbilityPhaseStart()
	--self:GetCaster():EmitSound("kisame_shark")
	--self:GetCaster():EmitSound("kisame_shark_cast")
	--return true
--end

function sai_super_god_drawing:OnSpellStart()
	self.area_of_effect = self:GetSpecialValueFor( "area_of_effect" )
	self.max_treants = self:GetSpecialValueFor( "max_treants" )
	self.duration = self:GetSpecialValueFor( "duration" )
	self.ability_lvl= self:GetLevel()

	local vTargetPosition = self:GetCursorPosition()
	local trees = GridNav:GetAllTreesAroundPoint( vTargetPosition, self.area_of_effect, true )
	local nTreeCount = #trees

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_furion/furion_force_of_nature_cast.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_staff_base", self:GetCaster():GetOrigin(), true )

	ParticleManager:SetParticleControl( nFXIndex, 1, vTargetPosition )
	ParticleManager:SetParticleControl( nFXIndex, 2, Vector( self.area_of_effect, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	GridNav:DestroyTreesAroundPoint( vTargetPosition, self.area_of_effect, true )
	EmitSoundOnLocationWithCaster(vTargetPosition, 
		"kisame_shark_cast", self:GetCaster()
	)
	self:GetCaster():EmitSound("kisame_shark")
	self:GetCaster():EmitSound("kisame_shark_cast")
	
	--kisame_bunshin
		local sai_god_drawing = CreateUnitByName( "sai_god_drawings",
			 vTargetPosition, true, self:GetCaster(),
			 self:GetCaster():GetOwner(),
			 self:GetCaster():GetTeamNumber() )
		if sai_god_drawing ~= nil then
			sai_god_drawing:SetControllableByPlayer( self:GetCaster():GetPlayerID(), false )
			sai_god_drawing:SetOwner( self:GetCaster() )
			sai_god_drawing:CreatureLevelUp(self.ability_lvl-1)
			 --get abnbilitylvl
			--TODO set lvl to copy check if ability lvls too

			--local kv = {duration = self.duration}
--timedlife o stats
			--hTreant:AddNewModifier( self:GetCaster(), self, "modifier_sai_super_god_drawing_lua", kv )
		end	
end

--------------------------------------------------------------------------------
--modifier 
modifier_sai_super_god_drawing_lua = class({})

--------------------------------------------------------------------------------

function modifier_sai_super_god_drawing_lua:IsDebuff()	return true end

--------------------------------------------------------------------------------

function modifier_sai_super_god_drawing_lua:IsHidden()	return true end

--------------------------------------------------------------------------------

function modifier_sai_super_god_drawing_lua:IsPurgable() return false
end

--------------------------------------------------------------------------------

function modifier_sai_super_god_drawing_lua:OnDestroy()
	if IsServer() then
		self:GetParent():ForceKill( false )
	end
end

--------------------------------------------------------------------------------

function modifier_sai_super_god_drawing_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_LIFETIME_FRACTION
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_sai_super_god_drawing_lua:GetUnitLifetimeFraction( params )
	return ((self:GetDieTime() - GameRules:GetGameTime()) / self:GetDuration())
end
