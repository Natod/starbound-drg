require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}
  
  self.movementSettings = config.getParameter("movementSettings")
  self.parentID = config.getParameter("parentID", 0)

  self.supplyTime = config.getParameter("supplyTime", 2)
  self.supplyProgress = 0

  vehicle.setPersistent(false)
  vehicle.setDamageTeam({type = "ghostly"})
  animator.setParticleEmitterActive("particleGlow", false)

  self.rackID = config.getParameter("rackID", 0)
  animator.setAnimationState("body", string.format("%s",self.rackID))
  --vehicle.destroy()
end

function update(dt)
  mcontroller.setXVelocity(0)
  mcontroller.applyParameters(self.movementSettings)

   
  local driver = vehicle.entityLoungingIn("seat")
  if driver then
    -- called when you first get in 
    if self.lastDriver == nil then

      --match the index of the driver's entityID to their position
      for i,p in pairs(self.nearbyPlayers) do
        if driver == p then
          --mcontroller.setPosition(vec2.add(self.playerPosList[p][2],{0,-2.65}))
          break
        end
      end
    end

    vehicle.setInteractive(false)
  else
     --passive
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
  
  
  local throwAnimationAngle = math.pi/4
  if vehicle.entityLoungingIn("seat") then
    if self.supplyProgress < self.supplyTime then
      animator.playSound("inProgress")
      self.supplyProgress = self.supplyProgress + dt / self.supplyTime
      if self.supplyProgress >= self.supplyTime then
        --resupply half the player ammo
        animator.playSound("finished")
        world.sendEntityMessage(self.parentID, "deep_resupplyEmpty")
        vehicle.destroy()
      end
    end
    --leave the supply pod if you try to move (small dead window)
    if self.supplyProgress > 0.4 and (vehicle.controlHeld("seat", "jump") or vehicle.controlHeld("seat", "right") or vehicle.controlHeld("seat", "left")) then
      vehicle.destroy()
      world.spawnVehicle("deep_resupply", mcontroller.position(), {rackID = self.rackID})
      self.supplyProgress = 0
    end
  else
    self.supplyProgress = 0
  end
    


end

--checks if the aquarq-like has the given tag and does its thing
function identifyType(query)
  local hasTag = false
  if deep_util.isInTable(query, self.objTags) then hasTag = true end
  return hasTag
end