require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end

function init()
  deep_init()

  self.callerHeight = mcontroller.yPosition() - config.getParameter("podSpawnHeight", 200)
  self.callerID = config.getParameter("callerID")

  message.setHandler("deep_callerHeight", function(messageName, isLocalEntity, value)
    self.callerHeight = value
  end)
  mcontroller.setYVelocity(-25)
end

function update()
  deep_update()

  if mcontroller.yPosition() <= self.callerHeight then
    world.sendEntityMessage(self.callerID, "deep_podLanded")
    projectile.die()
  end

  world.damageTiles(
    {
      {world.xwrap(math.floor(mcontroller.xPosition()-1+0.5)), math.floor(mcontroller.yPosition()+0.5)},
      --{world.xwrap(math.floor(mcontroller.xPosition())), math.floor(mcontroller.yPosition()+0.5)},
      {world.xwrap(math.floor(mcontroller.xPosition()+0.5)), math.floor(mcontroller.yPosition()+0.5)},
      --{world.xwrap(math.ceil(mcontroller.xPosition())), math.floor(mcontroller.yPosition()+0.5)},
      {world.xwrap(math.floor(mcontroller.xPosition()+1+0.5)), math.floor(mcontroller.yPosition()+0.5)}
    },
    "foreground",
    mcontroller.position(),
    "blockish",
    999999,
    99999
  )
    --world.placeMaterial()
end

function uninit()
  deep_uninit()

  world.spawnVehicle("deep_rpod",mcontroller.position())
end