if not GarbageCollector then
	print("init GarbageCollector...")
	GarbageCollector = class({})
	GarbageCollector.ACTIVE_PARTICLES = {}
	GarbageCollector.IGNORED_PARTICLES = {}
	GarbageCollector.IGNORED_PARTICLES["particles/dev/empty_particle.vpcf"] = true
end

-- Call custom functions whenever CreateParticle is being called anywhere
local original_CreateParticle = CScriptParticleManager.CreateParticle
CScriptParticleManager.CreateParticle = function(self, sParticleName, iAttachType, hParent)

--	print("CreateParticle response:", sParticleName)

	-- call the original function
	local response = original_CreateParticle(self, sParticleName, iAttachType, hParent)

	if not GarbageCollector.IGNORED_PARTICLES[sParticleName] then
		table.insert(GarbageCollector.ACTIVE_PARTICLES, {response, 0})
	end

	return response
end

-- Call custom functions whenever CreateParticleForTeam is being called anywhere
local original_CreateParticleForTeam = CScriptParticleManager.CreateParticleForTeam
CScriptParticleManager.CreateParticleForTeam = function(self, sParticleName, iAttachType, hParent, iTeamNumber)
--	print("Create Particle (override):", sParticleName, iAttachType, hParent, iTeamNumber, hCaster)

	-- call the original function
	local response = original_CreateParticleForTeam(self, sParticleName, iAttachType, hParent, iTeamNumber)

	if not GarbageCollector.IGNORED_PARTICLES[sParticleName] then
		table.insert(GarbageCollector.ACTIVE_PARTICLES, {response, 0})
	end

	return response
end

-- Call custom functions whenever CreateParticleForPlayer is being called anywhere
local original_CreateParticleForPlayer = CScriptParticleManager.CreateParticleForPlayer
CScriptParticleManager.CreateParticleForPlayer = function(self, sParticleName, iAttachType, hParent, hPlayer)
--	print("Create Particle (override):", sParticleName, iAttachType, hParent, hPlayer, hCaster)

	-- call the original function
	local response = original_CreateParticleForPlayer(self, sParticleName, iAttachType, hParent, hPlayer)

	if not GarbageCollector.IGNORED_PARTICLES[sParticleName] then
		table.insert(GarbageCollector.ACTIVE_PARTICLES, {response, 0})
	end

	return response
end

function GarbageCollector:OnThink()
	for k, v in pairs(self.ACTIVE_PARTICLES) do
		if v[2] >= 60 then
			if v[1] and type(v[1]) == "number" then
				ParticleManager:DestroyParticle(v[1], false)
				ParticleManager:ReleaseParticleIndex(v[1])
			end

			table.remove(self.ACTIVE_PARTICLES, k)
		else
			self.ACTIVE_PARTICLES[k][2] = self.ACTIVE_PARTICLES[k][2] + 1
		end
	end
end
