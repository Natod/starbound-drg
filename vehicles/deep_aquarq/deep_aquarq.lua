require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}
  --self.prevPlayerPosList = {}

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

  self.fireCooldown = 0.0

  vehicle.setPersistent(true)
  animator.setAnimationState("body", "unoccupied")
  --animator.setParticleEmitterActive("glow",true)
  animator.setParticleEmitterActive("particleGlowFloor",true)
  animator.setParticleEmitterActive("particleGlow",false)
end

function update(dt)

  if vehicle.entityLoungingIn("seat") == nil then
    self.nearbyPlayers = world.entityQuery(mcontroller.position(), self.detectRadius, {
      includedTypes = {"player"},
      boundMode = "CollisionArea",
      order = "nearest"
    })
    
    if #self.nearbyPlayers >0 then
      for i,p in pairs(self.nearbyPlayers) do 
        self.playerPosList[i] = world.entityPosition(p)
      end
    end
  end
  

  storage.health = 999999
  self.fireCooldown = self.fireCooldown - dt


  if mcontroller.atWorldLimit() then
    vehicle.destroy()
    return
  end

  -- called when you first get in 
  local driver = vehicle.entityLoungingIn("seat")
  if driver then
    if self.lastDriver == nil then
      --animator.playSound("engineStart")
      --animator.playSound("engineLoop", -1)

      --match the index of the driver's entityID to their position
      for i,p in pairs(self.nearbyPlayers) do
        if driver == p then
          mcontroller.setPosition(vec2.add(self.playerPosList[i],{0,-2.65}))
          Print(self.playerPosList[i])
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
  local aimSource = vec2.add(mcontroller.position(), animator.partPoint("cannon", "rotationCenter"))
  local mouseDir = vec2.norm(world.distance(aim, aimSource))
  local clampRange = {math.rad(self.minAngle), math.rad(self.maxAngle)}
  local aimAngle = util.clamp(math.atan(mouseDir[2], math.abs(mouseDir[1])), math.rad(self.minAngle), math.rad(self.maxAngle))
  animator.resetTransformationGroup("cannon")
  animator.rotateTransformationGroup("cannon", aimAngle, animator.partPoint("cannon", "rotationCenter"))
  
  if self.fireCooldown <= 0 and vehicle.controlHeld("seat", "primaryFire") then
    local firePosition = vec2.add(mcontroller.position(), animator.partPoint("cannon", "fireOffset"))
    local aimDir = vec2.withAngle(aimAngle)
    aimDir[1] = aimDir[1] * util.toDirection(mouseDir[1])
    --world.spawnProjectile("penguintankround", firePosition, entity.id(), aimDir, false)
    --animator.playSound("fire")
    --animator.burstParticleEmitter("muzzleFlash")

    self.fireCooldown = self.fireInterval
    local aimVector = (vec2.mul(vec2.sub(mcontroller.position(),vehicle.aimPosition("seat")),-1))
    vehicle.setLoungeEnabled("seat", false)
    world.spawnProjectile("deep_aquarq", vec2.add(mcontroller.position(), {0,2}), nil, vec2.norm(aimVector), nil, {speed = 30})
    vehicle.destroy()
    
    --mcontroller.setVelocity(vec2.mul(vec2.sub(mcontroller.position(),vehicle.aimPosition("seat")),-8))
    self.prevPlayerPosList = self.playerPosList
  end

  local localAim = world.distance(aim, mcontroller.position())
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

  --self.prevPlayerPosList = self.playerPosList
end

function applyDamage(damageRequest)
  local damage = 0
  if damageRequest.damageType == "Damage" then
    damage = damage + root.evalFunction2("protection", damageRequest.damage, self.protection)
  elseif damageRequest.damageType == "IgnoresDef" then
    damage = damage + damageRequest.damage
  else
    return {}
  end

  local healthLost = math.min(damage, storage.health)
  storage.health = storage.health - healthLost

  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damageDealt = damage,
    healthLost = healthLost,
    hitType = "Hit",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = "robotic",
    killed = storage.health <= 0
  }}
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