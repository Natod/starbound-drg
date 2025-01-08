require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.energyCostPerSecond = config.getParameter("energyCostPerSecond")
  self.active=false
  self.available = true
  self.species = world.entitySpecies(entity.id())
  self.firetimer = 0
  self.rechargeDirectives = "?fade=CC22CCFF=0.1"
  self.rechargeDirectivesNil = nil
  self.rechargeEffectTime = 0.1 
  self.rechargeEffectTimer = 0
  self.flashCooldownTimer = 0
  self.halted = 0
  self.flareCount = 4
  self.cooldownFinish = false
  self.regenFinish = false
end

function uninit()

end

function activeAbility()
    world.spawnProjectile("flare", mcontroller.position(), entity.id(), aimVector(), false)
end

function aimVector()
  local aimVector = vec2.rotate({1, 0}, sb.nrand(0, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end



    
function update(args)
	self.firetimer = math.max(0, self.firetimer - args.dt)


	

	if self.flashCooldownTimer > 0 then
		self.flashCooldownTimer = math.max(0, self.flashCooldownTimer - args.dt)  
		if self.flashCooldownTimer <= 2 then
			if self.halted == 0 then
				self.halted = 1
			end	 
		end

		if self.flashCooldownTimer == 0 then
			self.cooldownFinish = true	
				
		end
	end

	if self.rechargeEffectTimer > 0 then
		self.rechargeEffectTimer = math.max(0, self.rechargeEffectTimer - args.dt)
		if self.rechargeEffectTimer == 0 then
			tech.setParentDirectives()	
		end
	end
	
	

	if args.moves["special1"] and self.firetimer == 0 and self.flareCount >= 1 then 
		animator.playSound("activate")
		self.firetimer = 0.5
		activeAbility()
		self.dashCooldownTimer = 0.5
		self.flashCooldownTimer = 0.5
		self.flareCount = self.flareCount - 1
		self.halted = 0
		self.cooldownFinish = false
		self.regenFinish = false
	end
	

	if self.flareCount < 4 then
		self.flareCount = self.flareCount + (0.3 * args.dt)
		if self.flareCount >= 1 then
			self.regenFinish = true
		end
	else
		self.flareCount = 4
	end

	if self.cooldownFinish and self.regenFinish then
		self.rechargeEffectTimer = self.rechargeEffectTime
		tech.setParentDirectives(self.rechargeDirectives)
		animator.playSound("recharge")
		self.cooldownFinish = false
		self.regenFinish = false
	end
end
