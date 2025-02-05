require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}
  storage.health = storage.health or config.getParameter("health", 35)
  storage.kickedSoundFlag = storage.kickedSoundFlag or false
  
  self.movementSettings = config.getParameter("movementSettings")
  self.invulnerable = config.getParameter("invulnerable", false)
  if self.invulnerable then
    vehicle.setDamageTeam({type = "ghostly"})
  else
    vehicle.setDamageTeam({type = "passive"})
  end
  self.kickable = config.getParameter("kickable", false)

  animator.setAnimationState("body", "idle")
  --
  mcontroller.applyParameters(self.movementSettings)
  storage.kicked = storage.kicked or false
  local startVel = config.getParameter("velocity")
  if startVel and not storage.kicked then
    mcontroller.setVelocity(startVel)
    storage.kicked = true
  end
  self.kickForce = config.getParameter("kickForce")

  self.killOnReload = config.getParameter("killOnReload", false)
  if self.killOnReload then
    vehicle.setPersistent(false)
    if storage.reloadFlag then
      vehicle.destroy()
    end
    storage.reloadFlag = true
  else
    vehicle.setPersistent(true)
  end

end

function update(dt)
  
  if not storage.kickedSoundFlag then
    animator.playSound("smash")
    storage.kickedSoundFlag = true
  end
  local driver = vehicle.entityLoungingIn("seat")
  if driver then
    -- called when you first get in 
    if self.lastDriver == nil then
      --match the index of the driver's entityID to their position
      if self.kickable then
        for i,p in pairs(self.nearbyPlayers) do
          if driver == p then
            local dir = vec2.norm(world.distance(mcontroller.position(), vec2.add(self.playerPosList[p][2],{0,-5})))
            world.spawnVehicle("deep_barrel", mcontroller.position(), {
              velocity = vec2.add(vec2.mul(dir, self.kickForce), mcontroller.velocity()),
              invulnerable = self.invulnerable,
              health = storage.health,
              kickable = self.kickable,
              killOnReload = self.killOnReload
            })
            mcontroller.setPosition(vec2.add(self.playerPosList[p][2],{0,-2.65}))
            vehicle.destroy()
            break
          end
        end
      end
    end

    vehicle.setInteractive(false)
  else
    vehicle.setInteractive(true)
  end
  self.lastDriver = driver

  local spinny = false
  if driver == nil then
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
        --
        local playerX = world.entityPosition(p)[1] - 0
        local playerY = world.entityPosition(p)[2] - 2.5
        if  playerX > mcontroller.xPosition() - 1.7
        and playerX < mcontroller.xPosition() + 1.7
        and playerY > mcontroller.yPosition() + 2
        and playerY < mcontroller.yPosition() + 3.01 then
          --freak
          --sb.logInfo("freakin!!")
          local maxDisplacement = 1.25
          local poly = mcontroller.collisionPoly()
          --{{0,0},{0,1},{1,1},{1,0}}
          local resolvePos = world.resolvePolyCollision(poly, 
          vec2.add(mcontroller.position(),{
            (math.random()-0.5)*2 * maxDisplacement,
            (math.random()-0.5)*2 * maxDisplacement
          }), maxDisplacement)
          if resolvePos then
            mcontroller.setPosition(resolvePos)
            spinny = true
          end
        end
      end
    end
    if spinny then
      local rand = math.random()
      animator.rotateTransformationGroup("rotate", ((rand-0.5)*2)*rand * math.pi/3, {0,1.5})
      animator.playSound("smash")
    else
      animator.resetTransformationGroup("rotate")
      --animator.stopAllSounds("smash")
    end
  end
end

function applyDamage(damageRequest)
  local damage = 0
  damage = damage + damageRequest.damage

  local healthLost = math.min(damage, storage.health)
  storage.health = storage.health - healthLost
  if storage.health <= 0 then 
    --animator.setParticleEmitterBurstCount(1)
    animator.burstParticleEmitter("damageShards")
    vehicle.destroy()
  end
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