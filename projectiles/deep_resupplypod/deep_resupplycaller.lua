require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end

function init()
  deep_init()

  self.checkDist = config.getParameter("floorCheckDistance", 100)
  mcontroller.setPosition(checkFloor())
  self.spawnHeight = config.getParameter("podSpawnHeight", 200)
  --sb.logInfo(entity.id())
  for i=0,100 do
    self.pod = world.spawnProjectile(
      "deep_resupplypod", 
      vec2.add(mcontroller.position(), {0, self.spawnHeight-2*i}),
      entity.id(),
      nil,
      nil,
      {podSpawnHeight = self.spawnHeight, callerID = entity.id()}
    )
    if self.pod then break end
  end
  
  message.setHandler("deep_podLanded", function(messageName, isLocalEntity)
    projectile.die()
  end)
  
end

function update()
  deep_update()

  mcontroller.setPosition(checkFloor())
  world.sendEntityMessage(self.pod, "deep_callerHeight", mcontroller.yPosition())
end

function uninit()
  deep_uninit()


end

function checkFloor()
  local checkPos = vec2.add(mcontroller.position(), {0, -self.checkDist})
  local val = world.lineCollision(mcontroller.position(), checkPos, {"block","platform"})
  if val then
    return val
  else
    return checkPos
  end
end