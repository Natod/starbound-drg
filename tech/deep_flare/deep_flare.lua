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

	local timerPercent = self.holdTimer / self.resupplyTime
	local fadeVal = math.min(timerPercent + 0.65, 1)
	local timerBar = {
		position = vec2.add(vec2.sub(tech.aimPosition(), mcontroller.position()), {0,-2}),
		width = 4,
		inset = 1,
		length = 5,
		bgColor = {20, 20, 30, 200},
		fgColor = {
			150 + 100 * timerPercent^2, 
			150 + 100 * timerPercent^2, 
			150 + 100 * timerPercent^2, 
			200
		},
		progress = timerPercent,
		empty = false
	}
	local callText = {
		pos = vec2.add(vec2.sub(tech.aimPosition(), mcontroller.position()), {0,-4}),
		img = "/interface/text/deep_resupplytext.png",
		color = {
			255,
			255,
			255,
			0 + fadeVal^2*200
		},
		empty = false
	}

	if args.moves["special1"] and self.holdTimer >= 0 then
		self.holdTimer = self.holdTimer + args.dt
		timerBar.empty = false
		callText.empty = false
	else
		timerBar.empty = true
		callText.empty = true
	end

	world.sendEntityMessage(entity.id(), "deep_playerAnimatorBarUpdate", "flareTimerBar", timerBar)
	world.sendEntityMessage(entity.id(), "deep_playerAnimatorImgUpdate", "resupplyAbility", callText)

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
		local rayDist = 10
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
