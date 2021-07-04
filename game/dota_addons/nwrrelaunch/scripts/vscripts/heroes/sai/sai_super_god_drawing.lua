
sai_super_god_drawing = sai_super_god_drawing or class({})
LinkLuaModifier( "modifier_sai_super_god_drawing_lua",
				"heroes/sai/sai_super_god_drawing.lua",
				 LUA_MODIFIER_MOTION_NONE )
--todo check with DIGITALG
function sai_super_god_drawing:GetAOERadius()
	return self:GetSpecialValueFor("area_of_effect")
end
function sai_super_god_drawing:IsHiddenWhenStolen()return true end
function sai_super_god_drawing:OnSpellStart()
	self.area_of_effect = self:GetSpecialValueFor( "area_of_effect" )
	self.duration = self:GetSpecialValueFor( "duration" )
	self.ability_lvl= self:GetLevel()

	local vTargetPosition = self:GetCursorPosition()
	local trees = GridNav:GetAllTreesAroundPoint(vTargetPosition, self.area_of_effect, true)
	local nTreeCount = #trees
--TODO tbRefactored
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_furion/furion_force_of_nature_cast.vpcf", 
						PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(nFXIndex, 0, self:GetCaster(),
					 PATTACH_POINT_FOLLOW, "attach_staff_base", 
					 self:GetCaster():GetOrigin(), true )
	ParticleManager:SetParticleControl( nFXIndex, 1, vTargetPosition )
	ParticleManager:SetParticleControl( nFXIndex, 2, Vector( self.area_of_effect, 0, 0))
	ParticleManager:ReleaseParticleIndex( nFXIndex)

	GridNav:DestroyTreesAroundPoint( vTargetPosition, self.area_of_effect, true)
	--fx
	EmitSoundOnLocationWithCaster(vTargetPosition, 
		"kisame_shark_cast", self:GetCaster()
	)
	self:SpawnInitGodDrawings(vTargetPosition)
end

modifier_sai_super_god_drawing_lua = modifier_sai_super_god_drawing_lua or class({})

function modifier_sai_super_god_drawing_lua:IsBuff()	return true end
function modifier_sai_super_god_drawing_lua:IsHidden()	return true end
function modifier_sai_super_god_drawing_lua:IsPurgable()return false end
function modifier_sai_super_god_drawing_lua:OnDestroy()if IsServer() then end end
--------------------------------------------------------------------------------
--MS workaround.. gain not working properly or im missing something.. 
--DM for refactor
function modifier_sai_super_god_drawing_lua:DeclareFunctions()return{
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE 
}end
function modifier_sai_super_god_drawing_lua:GetModifierMoveSpeed_Absolute()return 
	360+ 20*(self:GetParent():GetLevel()-1)
end
--------------------------------------------------------------------------------
--helper func use loop?!-.- ; "lore" code :P
function sai_super_god_drawing:SpawnInitGodDrawings(vTargetPosition)
	local sai_gd_Agyo = self:SpawnGd(vTargetPosition)
	local sai_gd_Ungyo= self:SpawnGd(vTargetPosition)
	if (sai_gd_Agyo ~= nil and sai_gd_Ungyo ~= nil) then
		self:InitGdStats(sai_gd_Agyo)
		self:InitGdStats(sai_gd_Ungyo)
	end
end
function sai_super_god_drawing:InitGdStats(gdNPC)
 	gdNPC:SetControllableByPlayer( self:GetCaster():GetPlayerID(), false )
	gdNPC:SetOwner( self:GetCaster() )
	-- gdNPC:SetMoveSpeedGain(20)--test this!!
	gdNPC:SetHPRegenGain(20)--test this!!
	gdNPC:CreatureLevelUp(self.ability_lvl-1)
	--workaround for movespeed and hp regen . duration infinite
	gdNPC:AddNewModifier( self:GetCaster(), self, "modifier_sai_super_god_drawing_lua", nil)
end
function sai_super_god_drawing:SpawnGd(vTargetPosition)
 	return CreateUnitByName( "sai_god_drawings", vTargetPosition,
 		true, self:GetCaster(),
		self:GetCaster():GetOwner(),
		self:GetCaster():GetTeamNumber())
end