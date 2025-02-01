require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}
  self.selfProjectile = config.getParameter("selfProjectile")
  self.objTags = config.getParameter("objectTags", {})

  self.moveSpeed = config.getParameter("moveSpeed")
  self.groundForce = config.getParameter("groundForce")
  self.jumpSpeed = config.getParameter("jumpSpeed")
  
  self.movementSettings = config.getParameter("movementSettings")
  self.occupiedMovementSettings = config.getParameter("occupiedMovementSettings")

  self.minAngle = config.getParameter("minAngle")
  self.maxAngle = config.getParameter("maxAngle")
  self.fireInterval = config.getParameter("fireInterval")

  self.driving = false
  self.lastDriver = nil

  self.jumping = false

  self.throwPower = 0.0

  vehicle.setPersistent(true)
  vehicle.setLoungeEnabled("seat", true)
  animator.setAnimationState("body", "unoccupied")
  animator.setParticleEmitterActive("particleGlowFloor",true)
  animator.setParticleEmitterActive("particleGlow",false)
  
  message.setHandler("depositableType", depositableType)
end

function update(dt)

  
   
  local driver = vehicle.entityLoungingIn("seat")
  if driver then
    -- called when you first get in 
    if self.lastDriver == nil then

      --match the index of the driver's entityID to their position
      for i,p in pairs(self.nearbyPlayers) do
        if driver == p then
          mcontroller.setPosition(vec2.add(self.playerPosList[p][2],{0,-2.65}))
          break
        end
      end
    end

    vehicle.setDamageTeam({type = "ghostly"}) --world.entityDamageTeam(driver)
    mcontroller.applyParameters(self.occupiedMovementSettings)
    vehicle.setInteractive(false)
  else
    vehicle.setDamageTeam({type = "ghostly"}) --passive
    mcontroller.applyParameters(self.movementSettings)
    vehicle.setInteractive(true)
  end
  self.lastDriver = driver
  
  if vehicle.entityLoungingIn("seat") == nil then
    self.nearbyPlayers = world.entityQuery(mcontroller.position(), self.detectRadius, {
      includedTypes = {"player"},
      boundMode = "CollisionArea",
      order = "nearest"
    })
    
    -- Update list of player positions over last 2 ticks
    if #self.nearbyPlayers >0 then
      for i,p in pairs(self.nearbyPlayers) do 
        self.playerPosList[p] = self.playerPosList[p] or {}
        self.playerPosList[p][2] = self.playerPosList[p][1] or {0,0}
        self.playerPosList[p][1] = world.entityPosition(p)
      end
    end
  end
  

  local moveDir = 0
  if vehicle.controlHeld("seat", "right") then
    moveDir = moveDir + 1
  end
  if vehicle.controlHeld("seat", "left") then
    moveDir = moveDir - 1
  end
  if not self.jumping and mcontroller.onGround() and vehicle.controlHeld("seat", "jump") then
    self.jumping = true
    mcontroller.setYVelocity(self.jumpSpeed)
  end

  mcontroller.approachXVelocity(moveDir * self.moveSpeed, self.groundForce)

  local aim = vehicle.aimPosition("seat")
  local localAim = world.distance(aim, mcontroller.position())

  animator.setFlipped(localAim[1] < 0)
  if vehicle.entityLoungingIn("seat") then
    animator.setParticleEmitterActive("particleGlowFloor",false)
    animator.setParticleEmitterActive("particleGlow",true)
    animator.setAnimationState("body", "idle")
    if not mcontroller.onGround() then
      self.jumping = false
    end
  else
    vehicle.setLoungeEnabled("seat", true)
    animator.setAnimationState("body", "unoccupied")
    animator.setParticleEmitterActive("particleGlowFloor",true)
    animator.setParticleEmitterActive("particleGlow",false)
  end
  
  local maxThrowPower = 30
  local throwAnimationAngle = math.pi/4
  if vehicle.controlHeld("seat", "primaryFire") then
    if self.throwPower < maxThrowPower then
      self.throwPower = self.throwPower + dt * maxThrowPower
      animator.rotateTransformationGroup("rotate", -dt*throwAnimationAngle, {0.5,3})
      animator.translateTransformationGroup("rotate", {dt/3,-dt/4})
      if self.throwPower >= maxThrowPower then
        animator.playSound("recharge")
      end
    end
  elseif self.throwPower > 0.0 then
    local dir = vec2.sub(vehicle.aimPosition("seat"), mcontroller.position())
    vehicle.setLoungeEnabled("seat", false)
    animator.playSound("throw")
    heavyObjProjectile(localAim)
    --heavyObjThrow(dir, 8)
    self.throwPower = 0
    animator.resetTransformationGroup("rotate")    
    
  end


  local driving = moveDir ~= 0
  self.driving = driving

end

--checks if the aquarq-like has the given tag and does its thing
function identifyType(query)
  local hasTag = false
  if deep_util.isInTable(query, self.objTags) then hasTag = true end
  return hasTag
end

function depositableType()
  vehicle.destroy()
  return self.selfProjectile
end

function heavyObjProjectile(aim)
  --unused?
  world.spawnProjectile(self.selfProjectile, vec2.add(mcontroller.position(), {0,2}), nil, vec2.norm(aim), nil, {speed = self.throwPower})
  vehicle.destroy()
end

function heavyObjThrow(dir,power)
  mcontroller.setVelocity(vec2.mul(dir, power))
end
