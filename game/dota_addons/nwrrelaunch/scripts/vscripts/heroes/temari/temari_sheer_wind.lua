LinkLuaModifier("modifier_temari_sheer_wind_caster", "heroes/temari/temari_sheer_wind.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_temari_sheer_wind_stack_counter", "heroes/temari/temari_sheer_wind.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_temari_sheer_wind_stack_buff", "heroes/temari/temari_sheer_wind.lua", LUA_MODIFIER_MOTION_NONE)

temari_sheer_wind = class({})

function temari_sheer_wind:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function temari_sheer_wind:GetIntrinsicModifierName()
	return "modifier_temari_sheer_wind_caster"
end

function temari_sheer_wind:RefreshCounter()
	local caster = self:GetCaster()
	local counter = caster:FindModifierByName("modifier_temari_sheer_wind_stack_counter")
	counter:SetDuration(self:GetDuration(), true)
end

function temari_sheer_wind:ProcsMagicStick()
    return true
end

function temari_sheer_wind:ApplyStacks()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_temari_sheer_wind_stack_counter") then
		local counter = caster:FindModifierByName("modifier_temari_sheer_wind_stack_counter")
		if counter:GetStackCount() == self:GetSpecialValueFor("sheer_wind_max_stacks") then
			counter:SetDuration(self:GetDuration(), true)
		else
			counter:IncrementStackCount()
			counter:SetDuration(self:GetDuration(), true)
		end
		local buff_perc = counter:GetStackCount() / self:GetSpecialValueFor("sheer_wind_max_stacks") * 100
		ParticleManager:SetParticleControl(counter.buff_vfx, 10, Vector(buff_perc,0,0))

	else
		local new_modifier = caster:AddNewModifier(caster, self, "modifier_temari_sheer_wind_stack_counter", {duration = self:GetDuration()})
		new_modifier:SetStackCount(1)
		local buff_perc = 100
		ParticleManager:SetParticleControl(new_modifier.buff_vfx, 10, Vector(buff_perc,0,0))

	end
	
end

function temari_sheer_wind:DecreaseStack()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_temari_sheer_wind_stack_counter") then
		local counter = caster:FindModifierByName("modifier_temari_sheer_wind_stack_counter")
		if counter:GetStackCount() == 1 then
			caster:RemoveModifierByName("modifier_temari_sheer_wind_stack_counter")
		else
			counter:DecrementStackCount()
			local buff_perc = counter:GetStackCount() * 100
			ParticleManager:SetParticleControl(counter.buff_vfx, 10, Vector(buff_perc,0,0))
		end
	end
end


modifier_temari_sheer_wind_caster = class({})

function modifier_temari_sheer_wind_caster:IsHidden() return true end
function modifier_temari_sheer_wind_caster:IsPassive() return true end

function modifier_temari_sheer_wind_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED 
	}
end

function modifier_temari_sheer_wind_caster:OnAbilityExecuted(event)
	if event.ability:IsItem() then return end
	local ability = self:GetAbility()
	local caster = ability:GetCaster()

	local min_duration = 0

	if not IsServer() then return end
	local buff_modifiers = caster:FindAllModifiersByName("modifier_temari_sheer_wind_stack_buff")
	local buff_to_refresh = buff_modifiers[1]


	if #buff_modifiers >= 3 then

		for i=1,#buff_modifiers do
			if buff_modifiers[i]:GetElapsedTime() > min_duration then
				buff_to_refresh = buff_modifiers[i]
				min_duration = buff_modifiers[i]:GetElapsedTime()
			end
		end

		buff_to_refresh:SetDuration(ability:GetDuration(), true)
		ability:RefreshCounter()
	else
		caster:AddNewModifier(caster, ability, "modifier_temari_sheer_wind_stack_buff", {duration = ability:GetDuration()})
	end

end

modifier_temari_sheer_wind_stack_counter = class({})

function modifier_temari_sheer_wind_stack_counter:IsHidden() return false end
function modifier_temari_sheer_wind_stack_counter:IsPassive() return false end

function modifier_temari_sheer_wind_stack_counter:OnCreated()
	self.buff_vfx = ParticleManager:CreateParticle("particles/units/heroes/temari/temari_sheer_wind_buff.vpcf",
												   PATTACH_CUSTOMORIGIN_FOLLOW,
												   self:GetAbility():GetCaster())
	local buff_perc = 1 / self:GetAbility():GetSpecialValueFor("sheer_wind_max_stacks") * 100
	-- COntrol Point 10: X - is percentage of buff power, e.g. 1 our of 3 max stacks = 33%
	ParticleManager:SetParticleControl(self.buff_vfx, 10, Vector(buff_perc, 0, 0))
	ParticleManager:SetParticleControlEnt(self.buff_vfx, 0, self:GetAbility():GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", Vector(0,0,0), false)
	ParticleManager:SetParticleControlEnt(self.buff_vfx, 3, self:GetAbility():GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", Vector(0,0,0), false)
end

function modifier_temari_sheer_wind_stack_counter:OnRemoved()
	ParticleManager:DestroyParticle(self.buff_vfx, false)
	ParticleManager:ReleaseParticleIndex(self.buff_vfx)
end


modifier_temari_sheer_wind_stack_buff = class({})

function modifier_temari_sheer_wind_stack_buff:IsHidden() return false end
function modifier_temari_sheer_wind_stack_buff:IsPassive() return false end

function modifier_temari_sheer_wind_stack_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_temari_sheer_wind_stack_buff:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_temari_sheer_wind_stack_buff:OnCreated()
	local ability4 = self:GetAbility():GetCaster():FindAbilityByName("special_bonus_temari_4")
	if ability4 ~= nil then
	    if ability4:GetLevel() > 0 then --using GetLevel instead of IsTrained because IsTrained isn't abailable on client
	    	self.movespeed_bonus = self:GetAbility():GetSpecialValueFor("sheer_wind_move_speed_bonus_special")
	    	self.attackspeed_bonus = self:GetAbility():GetSpecialValueFor("sheer_wind_attack_speed_bonus_special")
	    else
	    	self.movespeed_bonus = self:GetAbility():GetSpecialValueFor("sheer_wind_move_speed_bonus")
	    	self.attackspeed_bonus = self:GetAbility():GetSpecialValueFor("sheer_wind_attack_speed_bonus")
	    end
	end

	self:GetAbility():ApplyStacks()
end

function modifier_temari_sheer_wind_stack_buff:OnRemoved()
	self:GetAbility():DecreaseStack()

end

function modifier_temari_sheer_wind_stack_buff:GetModifierMoveSpeedBonus_Percentage() 
	return self.movespeed_bonus
end

function modifier_temari_sheer_wind_stack_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed_bonus
end
