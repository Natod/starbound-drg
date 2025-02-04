require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  self.detectRadius = config.getParameter("detectRadius")
  self.playerPosList = {}
  self.nearbyPlayers = {}
  
  self.movementSettings = config.getParameter("movementSettings")
  vehicle.setPersistent(true)
  vehicle.setDamageTeam({type = "ghostly"})
  animator.setParticleEmitterActive("particleGlow", false)

  self.rackID = config.getParameter("rackID", 0)
  animator.setAnimationState("body", string.format("%s",self.rackID))
  --vehicle.destroy()
  
  message.setHandler("deep_destroyRack", function(messageName, isLocalEntity)
    vehicle.destroy()
  end)
end

function update(dt)
  mcontroller.setXVelocity(0)
  mcontroller.applyParameters(self.movementSettings)
  mcontroller.setXPosition(self.xpos)
   
  local driver = vehicle.entityLoungingIn("seat")
  if driver then
    -- called when you first get in 
    if self.lastDriver == nil then
      animator.playSound("inProgress")
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
    animator.stopAllSounds("inProgress")
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

  local supplyPercent = self.supplyProgress / self.supplyTime
  local resupplyBar = {
    position = {0,2},
    width = 3,
    inset = 1,
    length = 3,
    bgColor = {20, 20, 30, 200},
    fgColor = {
      125 + 100 * supplyPercent^2, 
      125 + 100 * supplyPercent^2, 
      125 + 100 * supplyPercent^2, 
      200},
    progress = supplyPercent,
    empty = false
  }
  
  if driver then
    if self.supplyProgress < self.supplyTime then

      self.supplyProgress = self.supplyProgress + dt / self.supplyTime
      if self.supplyProgress >= self.supplyTime then
        --resupply half the player ammo
        animator.stopAllSounds("inProgress")
        world.sendEntityMessage(self.parentID, "deep_resupplyEmpty")
        world.sendEntityMessage(driver, "deep_resupplyFactor", 0.5)
        resupplyBar.empty = true
        vehicle.destroy()
      end
    end
    --leave the supply pod if you try to move (small dead window)
    if self.supplyProgress > 0.4 and (vehicle.controlHeld("seat", "jump") or vehicle.controlHeld("seat", "right") or vehicle.controlHeld("seat", "left")) then
      animator.stopAllSounds("inProgress")
      resupplyBar.empty = true
      vehicle.destroy()
      world.spawnVehicle("deep_resupply", mcontroller.position(), {rackID = self.rackID, parentID = self.parentID})
      self.supplyProgress = 0
    end
    --update the progress bar display
    world.sendEntityMessage(driver, "deep_playerAnimatorBarUpdate", "resupplyBar", resupplyBar)
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