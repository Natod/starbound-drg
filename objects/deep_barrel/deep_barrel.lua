require "/scripts/util.lua"

function init()
  world.spawnVehicle("deep_barrel", entity.position())
  object.smash(true)
end