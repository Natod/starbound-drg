require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

function init()
  
end

function update(dt)
  
end

function uninit()
  world.spawnVehicle("deep_aquarq", mcontroller.position(), {})
end
