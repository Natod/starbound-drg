require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

function init()
  self.thrownObj = config.getParameter("thrownObj", "jeep")
end

function update(dt)
  
end

function uninit()
  world.spawnVehicle(self.thrownObj, mcontroller.position(), {})
end
