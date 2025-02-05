require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
	self.flareCount = config.getParameter("flareCount")
	self.fireTime = config.getParameter("fireTime")
	self.fireTimer = 0
	self.rechargeDirectives = "?fade=FFFFFFFF=0.1"
	self.rechargeEffectTime = 0.1
	self.rechargeEffectTimer = 0
	self.flashCooldownTimer = 0
	self.cooldownFinish = false
	self.regenFinish = false
	self.holdTimer = 0
	self.resupplyTime = config.getParameter("resupplyTime")
end

function uninit()
	tech.setParentDirectives()
end

function aimVector()
	local diff = world.distance(tech.aimPosition(), mcontroller.position())
	return vec2.norm(diff)
end

function update(args)
	self.fireTimer = math.max(0, self.fireTimer - args.dt)

	if self.flashCooldownTimer > 0 then
		self.flashCooldownTimer = math.max(0, self.flashCooldownTimer - args.dt)  
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
	
	if args.moves["special1"] and self.holdTimer >= 0 then
		self.holdTimer = self.holdTimer + args.dt
	end

	if not args.moves["special1"] then
		if self.holdTimer > 0 and self.holdTimer < self.resupplyTime and self.fireTimer == 0 and self.flareCount >= 1 then
			--throw flare
			animator.playSound("activate")
			world.spawnProjectile("deep_flareblue", mcontroller.position(), entity.id(), aimVector(), false)
			self.fireTimer = self.fireTime
			self.flashCooldownTimer = self.fireTime
			self.flareCount = self.flareCount - 1
			self.cooldownFinish = false
			self.regenFinish = false
		end
		self.holdTimer = 0
	end
	if self.holdTimer > self.resupplyTime then
		--summon resupply pod
		local rayDist = 20
		local distVec = vec2.sub(tech.aimPosition(), mcontroller.position())
		local distMag = vec2.mag(distVec)
		local unitVec = vec2.norm(distVec)
		local endVec = vec2.add(mcontroller.position(), vec2.mul(unitVec, math.min(rayDist, distMag)))
		local pos = world.lineCollision(mcontroller.position(), endVec) or endVec
		pos = vec2.sub(pos, vec2.mul(unitVec, 0.1))
		world.spawnProjectile("deep_resupplycaller", pos, entity.id())
		self.holdTimer = -1
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
