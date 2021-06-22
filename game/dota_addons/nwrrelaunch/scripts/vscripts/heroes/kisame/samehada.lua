
--[[
	Author: LearningDave
	Date: december, 6th 2015.
	Steals mana from target
]]
function StealManaBunshin( event )

	if (event.ability:IsCooldownReady()) then
		if not event.target:IsBuilding() and event.target:GetMaxMana() > 0 and not event.target:IsMagicImmune() then
			-- Variables
			local caster = event.caster
			local ability = event.ability
			local target = event.target
			local manasteal_percentage = event.ability:GetLevelSpecialValueFor("manasteal_percentage", event.ability:GetLevel() - 1 )
			local mana = target:GetMana()
			target:EmitSound("kisame_samehada_trigger")
			local reduce_mana_amount = target:GetMana() / 100 * manasteal_percentage
			local new_mana = mana - reduce_mana_amount
			target:SetMana(new_mana)
	
			local mana_for_kisame = reduce_mana_amount / 2
			caster:GetOwner():SetMana(caster:GetOwner():GetMana() + mana_for_kisame)
	
			-- Fire particle
			local fxIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_CUSTOMORIGIN, target )
			ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
			ParticleManager:SetParticleControlEnt( fxIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )

			event.ability:StartCooldown(event.ability:GetCooldown(event.ability:GetLevel() - 1))
		end

	end

	
end

