 neji_byakugan = class({})
 LinkLuaModifier( "modifier_neji_byakugan_buff", "scripts/vscripts/heroes/neji/neji_byakugan.lua", LUA_MODIFIER_MOTION_NONE )
 LinkLuaModifier( "modifier_neji_byakugan_debuff", "scripts/vscripts/heroes/neji/neji_byakugan.lua", LUA_MODIFIER_MOTION_NONE )
 
 function neji_byakugan:GetBehavior()
	 return self.BaseClass.GetBehavior(self)
 end
 
 function neji_byakugan:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
 end
 
 function neji_byakugan:ProcsMagicStick()
    return true
end
 
 function neji_byakugan:OnSpellStart()
	if IsServer() then
		local caster 	= self:GetCaster();
		local ability 	= self;
		neji_byakugan:ToggleOn(caster, ability);
	end
 end
 
 function neji_byakugan:OnToggle()
	if IsServer() then 
		local toggle 	= self:GetToggleState();
		local caster 	= self:GetCaster();
		local ability 	= self;

		if toggle == true then 
			neji_byakugan:ToggleOn(caster, ability);
		else 
			caster:RemoveModifierByName("modifier_neji_byakugan_buff");
		end
	end
end

function neji_byakugan:ToggleOn(caster, ability)
	
	-- This is to prevent Scepter pickup/refresh abuse into a 0 mana infinite duration modifier
	caster:RemoveModifierByName("modifier_neji_byakugan_buff");
	
	caster:EmitSound("neji_byakugan_activate");

	caster:AddNewModifier(caster, ability, "modifier_neji_byakugan_buff", {});
end


modifier_neji_byakugan_buff = modifier_neji_byakugan_buff or class({})

function modifier_neji_byakugan_buff:IsHidden() return false end
function modifier_neji_byakugan_buff:IsBuff() return true end

function modifier_neji_byakugan_buff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_neji_byakugan_buff:OnCreated()

	-- add particle to neji  "particles/units/heroes/neji/byakugan/byakugan_buff.vpcf"
	self.pfx = ParticleManager:CreateParticle( "particles/units/heroes/neji/byakugan/byakugan_buff.vpcf", PATTACH_POINT, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( self.pfx, 0, self:GetCaster(), PATTACH_POINT, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false )

	-- start interval for mana lose
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_neji_byakugan_buff:OnDestroy()
	ParticleManager:DestroyParticle(self.pfx, true)
	
	self:GetCaster():EmitSound("neji_byakugan_off")
end

function modifier_neji_byakugan_buff:OnIntervalThink()
	if self.caster == nil then return end
	if IsServer() then
		local maxMana = self.caster:GetMaxMana()
		local mana_lose_percentage = self.ability:GetSpecialValueFor("mana_lose_percentage")
		self.caster:SetMana(self.caster:GetMana() - (maxMana / 100 * 2.5))


		-- find enemies in x aoe
		local vision_aoe = self.ability:GetSpecialValueFor("vision_aoe")
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			vision_aoe,
			self.ability:GetAbilityTargetTeam(),
			DOTA_UNIT_TARGET_HERO,
			self.ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)

		for _, hero in pairs(enemies) do
			-- make them visable for enemy team
			hero:AddNewModifier(self.caster, self:GetAbility(), "modifier_neji_byakugan_debuff", {duration = 1})
		end

	end
end
 
function modifier_neji_byakugan_buff:OnAttackLanded( keys )

	if keys.attacker ~= self:GetAbility():GetCaster() then return end

	if (keys.target:IsHero() or keys.target:IsIllusion() or keys.target:IsCreep()) and keys.target:GetMaxMana() > 0 then

		if keys.target:IsHero() or keys.target:IsCreep() then 


			local caster = keys.attacker
			local ability = self:GetAbility()
			local target = keys.target
			
			target:EmitSound("neji_byakugan_mana_burn")
			
			local manaburn_percentage = ability:GetSpecialValueFor("mana_burn_percentage") + self:GetCaster():FindTalentValue("special_bonus_neji_2")
			local manaburn_flat = ability:GetSpecialValueFor("mana_burn_flat")
		
			
			local mana = target:GetMana()
			local reduce_mana_amount = (target:GetMaxMana() / 100 * manaburn_percentage) + manaburn_flat
			local new_mana = mana - reduce_mana_amount


			target:SetMana(new_mana)

			if mana > 0 then
				local damage = reduce_mana_amount / 2

				if (mana - reduce_mana_amount) < 0 then 
					damage = mana / 2
					reduce_mana_amount = mana
				end

				PopupManaDrain(target,math.floor(reduce_mana_amount))
				ApplyDamage({
					victim = target,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				})
			end

		
		end
	
		if keys.target:IsIllusion() then
			local caster = keys.attacker
			local ability = self.ability
			local target = keys.target
			
			target:EmitSound("neji_byakugan_mana_burn")
			
			local manaburn_percentage = (ability:GetSpecialValueFor("mana_burn_percentage")  + self:GetCaster():FindTalentValue("special_bonus_neji_2")) / 2
			local manaburn_flat = ability:GetSpecialValueFor("mana_burn_flat") / 2
		
			
			local mana = target:GetMana()
			local reduce_mana_amount = (target:GetMaxMana() / 100 * manaburn_percentage) + manaburn_flat
			local new_mana = mana - reduce_mana_amount
			target:SetMana(new_mana)

			if mana > 0 then
				local damage = reduce_mana_amount / 100 * 25

				if (mana - reduce_mana_amount) < 0 then 
					damage = mana / 100 * 25
					reduce_mana_amount = mana
				end
	
				PopupManaDrain(target,math.floor(reduce_mana_amount))
				PopupDamage(target,math.floor(damage))
				ApplyDamage({
					victim = target,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				})
			end
		
		end
	end
end
 
 
modifier_neji_byakugan_debuff = modifier_neji_byakugan_debuff or class({})

function modifier_neji_byakugan_debuff:IsHidden() return false end
function modifier_neji_byakugan_debuff:IsDebuff() return true end

function modifier_neji_byakugan_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
end

function modifier_neji_byakugan_debuff:GetModifierProvidesFOWVision()
	return 1
end