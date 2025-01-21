require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}

  self.moveSpeed = config.getParameter("moveSpeed")
  self.groundForce = config.getParameter("groundForce")
  self.jumpSpeed = config.getParameter("jumpSpeed")
  
  self.movementSettings = config.getParameter("movementSettings")
  self.occupiedMovementSettings = config.getParameter("occupiedMovementSettings")

  self.minAngle = config.getParameter("minAngle")
  self.maxAngle = config.getParameter("maxAngle")
  self.fireInterval = config.getParameter("fireInterval")

  self.protection = 999999
  storage.health = 999999

  self.driving = false
  self.lastDriver = nil

  self.jumping = false

  self.throwPower = 0.0

  vehicle.setPersistent(true)
  animator.setAnimationState("body", "unoccupied")
  --animator.setParticleEmitterActive("glow",true)
  animator.setParticleEmitterActive("particleGlowFloor",true)
  animator.setParticleEmitterActive("particleGlow",false)
end

function update(dt)

   -- called when you first get in 
  local driver = vehicle.entityLoungingIn("seat")
  if driver then
    if self.lastDriver == nil then
      --animator.playSound("engineStart")
      --animator.playSound("engineLoop", -1)

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
    --animator.stopAllSounds("engineLoop")
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

  if vehicle.controlHeld("seat", "primaryFire") then
    if self.throwPower < 30 then
      self.throwPower = self.throwPower + dt * 20
    end
  elseif self.throwPower > 0.0 then
    --animator.playSound("fire")
    vehicle.setLoungeEnabled("seat", false)
    world.spawnProjectile("deep_aquarq", vec2.add(mcontroller.position(), {0,2}), nil, vec2.norm(localAim), nil, {speed = self.throwPower})
    vehicle.destroy()
    
    --mcontroller.setVelocity(vec2.mul(vec2.sub(mcontroller.position(),vehicle.aimPosition("seat")),-8))
  end

  animator.setFlipped(localAim[1] < 0)
  if vehicle.entityLoungingIn("seat") then
    animator.setParticleEmitterActive("particleGlowFloor",false)
    animator.setParticleEmitterActive("particleGlow",true)
    if mcontroller.onGround() then
      if math.abs(moveDir) > 0 then
        if moveDir * localAim[1] > 0 then
          animator.setAnimationState("body", "move")
        else
          animator.setAnimationState("body", "movebackwards")
        end
      else
        animator.setAnimationState("body", "idle")
      end
    else
      self.jumping = false
      if mcontroller.yVelocity() > 0.0 then
        animator.setAnimationState("body", "jump")
      else
        animator.setAnimationState("body", "fall")
      end
    end
  else
    vehicle.setLoungeEnabled("seat", true)
    animator.setAnimationState("body", "unoccupied")
    animator.setParticleEmitterActive("particleGlowFloor",true)
    animator.setParticleEmitterActive("particleGlow",false)
  end

  local driving = moveDir ~= 0
  if driving and not self.driving then
    animator.playSound("engineDrive", -1)
  elseif not driving then
    animator.stopAllSounds("engineDrive", 0.5)
  end
  self.driving = driving

end

--[[
function positionOffset()
  return minY(self.transformedMovementParameters.collisionPoly) - minY(self.basePoly)
end

function transformPosition(pos)
  pos = pos or mcontroller.position()
  local groundPos = world.resolvePolyCollision(self.transformedMovementParameters.collisionPoly, {pos[1], pos[2] - positionOffset()}, 1, self.collisionSet)
  if groundPos then
    return groundPos
  else
    return world.resolvePolyCollision(self.transformedMovementParameters.collisionPoly, pos, 1, self.collisionSet)
  end
end

]]