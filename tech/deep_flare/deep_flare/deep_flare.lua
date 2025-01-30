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
	
	if args.moves["special1"] and self.fireTimer == 0 and self.flareCount >= 1 then 
		animator.playSound("activate")
		world.spawnProjectile("deep_flareblue", mcontroller.position(), entity.id(), aimVector(), false)
		self.fireTimer = self.fireTime
		self.flashCooldownTimer = self.fireTime
		self.flareCount = self.flareCount - 1
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
