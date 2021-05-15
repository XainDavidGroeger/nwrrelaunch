--[[Author: LearningDave
	Date: 04.11.2015
	Applies damage to target and fires a impact effect after x sec delay
	- Converted from datadriven to lua by EarthSalamander
	- Date: 27.04.2021
]]

LinkLuaModifier("modifier_gaara_sabaku_kyuu", "scripts/vscripts/heroes/gaara/sabaku_kyuu.lua", LUA_MODIFIER_MOTION_NONE)

gaara_sabaku_kyuu = gaara_sabaku_kyuu or class({})

function gaara_sabaku_kyuu:CanBeReflected(bool, target)
    if bool == true then
        if target:TriggerSpellReflect(self) then return end
    else
        --[[ simulate the cancellation of the ability if it is not reflected ]]
        ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN, target)
        EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
    end
end

function gaara_sabaku_kyuu:ProcsMagicStick()
    return true
end

function gaara_sabaku_kyuu:OnSpellStart()
	if not IsServer() then return end

	self.target = self:GetCursorTarget()

	self.target:EmitSound("gaara_prison_cast")
	self:GetCaster():EmitSound("gaara_prison_talking")

	--[[ if the target used Lotus Orb, reflects the ability back into the caster ]]
    if self.target:FindModifierByName("modifier_item_lotus_orb_active") then
        self:CanBeReflected(false, self.target)
		
        return
    end
    
    --[[ if the target has Linken's Sphere, cancels the use of the ability ]]
    if self.target:TriggerSpellAbsorb(self) then return end

	if self.target and self.target:IsAlive() and not self.target:IsOutOfGame() then
		self.target:AddNewModifier(self:GetCaster(), self, "modifier_gaara_sabaku_kyuu", {duration = self:GetSpecialValueFor("duration")})
	end
end

function gaara_sabaku_kyuu:OnChannelFinish(bInterrupted)
	if not IsServer() then return end

	if bInterrupted == true then
		if self.target and self.target:IsAlive() and not self.target:IsOutOfGame() then
			self.target:RemoveModifierByNameAndCaster("modifier_gaara_sabaku_kyuu", self:GetCaster())
		end
	end
end

modifier_gaara_sabaku_kyuu = modifier_gaara_sabaku_kyuu or class({})

function modifier_gaara_sabaku_kyuu:IsHidden() return true end
function modifier_gaara_sabaku_kyuu:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_gaara_sabaku_kyuu:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_gaara_sabaku_kyuu:GetOverrideAnimation() return ACT_DOTA_DISABLED end

function modifier_gaara_sabaku_kyuu:OnCreated()
	if not IsServer() then return end

	local knockback_param = {
		should_stun = 1,
		knockback_duration = self:GetAbility():GetSpecialValueFor("duration"),
		duration = self:GetAbility():GetSpecialValueFor("duration"),
		knockback_distance = 0,
		knockback_height = 200,
		center_x = self:GetParent().x,
		center_y = self:GetParent().y,
		center_z = self:GetParent().z,
	}

	self:GetParent():RemoveModifierByName("modifier_knockback")
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback_param)

	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/gaara/sandsturm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(200, 200, 0))

	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("delay_to_dmg"))
end

function modifier_gaara_sabaku_kyuu:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_gaara_sabaku_kyuu") then
		local damage = self:GetAbility():GetSpecialValueFor("dmg") + self:GetCaster():FindTalentValue("special_bonus_gaara_4")

		PopupDamage(self:GetParent(), damage)

		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType()
		})

		self:GetParent():EmitSound("gaara_prison_impact")

		local enemy_loc = self:GetParent():GetAbsOrigin()

		local impact_pfx = ParticleManager:CreateParticle("particles/units/heroes/gaara/sandstorm_explosion/sandstorm_explosion.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(impact_pfx, 0, enemy_loc)
		ParticleManager:SetParticleControlEnt(impact_pfx, 3, self:GetParent(), PATTACH_ABSORIGIN, "attach_origin", enemy_loc, true)
	end

	self:StartIntervalThink(-1)
end

function modifier_gaara_sabaku_kyuu:OnDestroy()
	if not IsServer() then return end

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end

	self:GetParent():RemoveModifierByNameAndCaster("modifier_knockback", self:GetCaster())
end
