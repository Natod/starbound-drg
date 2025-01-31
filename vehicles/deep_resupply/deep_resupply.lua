require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}
  
  self.movementSettings = config.getParameter("movementSettings")

  self.supplyTime = config.getParameter("supplyTime")

  self.jumping = false

  self.racks = {}
  storage.racksAvailable = {}
  for i=1,4 do 
    self.racks[i] = {
      supplyProgress = 0,
      lastDriver = nil
    }
    if storage.racksAvailable[i] == nil then
      storage.racksAvailable[i] = true
    end
  end

  vehicle.setPersistent(true)
  --animator.setAnimationState("body", "unoccupied")
  --animator.setParticleEmitterActive("particleGlowFloor",true)
  --animator.setParticleEmitterActive("particleGlow",false)
  
end

function update(dt)

  mcontroller.applyParameters(self.movementSettings)

   
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
    vehicle.setInteractive(false)
  else
    vehicle.setDamageTeam({type = "ghostly"}) --passive
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
  

  mcontroller.setXVelocity(0)
  
  local aim = vehicle.aimPosition("seat")
  local localAim = world.distance(aim, mcontroller.position())
  local maxThrowPower = 30
  local throwAnimationAngle = math.pi/4
  if vehicle.controlHeld("seat", "primaryFire") then
    if self.supplyProgress < maxThrowPower then
      self.supplyProgress = self.supplyProgress + dt * maxThrowPower
      animator.rotateTransformationGroup("rotate", -dt*throwAnimationAngle, {0.5,3})
      animator.translateTransformationGroup("rotate", {dt/3,-dt/4})
      if self.supplyProgress >= maxThrowPower then
        animator.playSound("recharge")
      end
    end
  elseif self.supplyProgress > 0.0 then
    vehicle.setLoungeEnabled("seat", false)
    animator.playSound("throw")
    world.spawnProjectile(self.selfProjectile, vec2.add(mcontroller.position(), {0,2}), nil, vec2.norm(localAim), nil, {speed = self.supplyProgress})
    vehicle.destroy()
    
    --mcontroller.setVelocity(vec2.mul(vec2.sub(mcontroller.position(),vehicle.aimPosition("seat")),-8))
  end

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
