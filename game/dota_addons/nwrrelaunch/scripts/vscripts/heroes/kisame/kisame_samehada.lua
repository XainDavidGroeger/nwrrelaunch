
kisame_samehada = kisame_samehada or class({})

LinkLuaModifier("modifier_kisame_samehada", "scripts/vscripts/heroes/kisame/kisame_samehada.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kisame_samehada_bonus_damage", "scripts/vscripts/heroes/kisame/kisame_samehada.lua", LUA_MODIFIER_MOTION_NONE)

function kisame_samehada:Precache(context)
	PrecacheResource("soundfile",  "soundevents/kisame_samehada_trigger.vsndevts", context)
	PrecacheResource("particle",   "particles/generic_gameplay/generic_manaburn.vpcf", context)
end

function kisame_samehada:GetIntrinsicModifierName()
	return "modifier_kisame_samehada"
end

function kisame_samehada:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel)
end

function kisame_samehada:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

modifier_kisame_samehada = modifier_kisame_samehada or class({})

function modifier_kisame_samehada:IsHidden() return false end

function modifier_kisame_samehada:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_kisame_samehada:OnCreated()
	self.ability = self:GetAbility()
end

--function modifier_kisame_samehada:IsHidden() return true end

function modifier_kisame_samehada:OnAttackLanded(keys)
    if keys.attacker ~= self:GetParent() then return end
	
	if self.ability:IsCooldownReady() then
		if (keys.target:IsHero() or keys.target:IsIllusion()) and keys.target:GetMaxMana() > 0 then
			-- Variables
			local caster = keys.attacker
			local ability = self.ability
			local target = keys.target
			
			target:EmitSound("kisame_samehada_trigger")
	
			local manasteal_percentage = ability:GetSpecialValueFor("manasteal_percentage")
	
	        local can_up_bunshins_samehada = false
			local ability3 = caster:FindAbilityByName("special_bonus_kisame_3")
			if ability3 ~= nil then
				if ability3:IsTrained() then
					manasteal_percentage = manasteal_percentage + 7.0
					can_up_bunshins_samehada = true
				end
			end
			
			if self:GetParent():GetUnitName() == "kisame_bunshin" and can_up_bunshins_samehada then
			    manasteal_percentage = manasteal_percentage + 7.0
			end
	
			local mana = target:GetMana()
			print("steal percentage: "..manasteal_percentage)
			print("start mana: "..mana)
			local reduce_mana_amount = target:GetMaxMana() / 100 * manasteal_percentage
			local new_mana = mana - reduce_mana_amount
			target:SetMana(new_mana)
			local new_caster_mana = caster:GetMana() + reduce_mana_amount;
			caster:SetMana(new_caster_mana)
	
			local bonus_damage = reduce_mana_amount / 100 * 40
			print(bonus_damage)
			-- add bonus dmg based on stolen mana
			caster:AddNewModifier(caster, ability, "modifier_kisame_samehada_bonus_damage", {
				duration = 10.0,
				bonus_damage = bonus_damage
			})

			self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()))
	
			-- Fire particle
			local fxIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_CUSTOMORIGIN, target )
			ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
			ParticleManager:SetParticleControlEnt( fxIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
		end
	end
	
end

modifier_kisame_samehada_bonus_damage = modifier_kisame_samehada_bonus_damage or class({})

function modifier_kisame_samehada_bonus_damage:OnCreated(keys) 
	if IsServer() then
		self:SetStackCount(keys.bonus_damage)
	end
end

function modifier_kisame_samehada_bonus_damage:DeclareFunctions() return {
	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
} end

function modifier_kisame_samehada_bonus_damage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end


