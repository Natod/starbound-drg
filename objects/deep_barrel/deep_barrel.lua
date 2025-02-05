require "/scripts/util.lua"

function init()
  local barrelConfig = config.getParameter("barrelConfig", {})
  world.spawnVehicle("deep_barrel", entity.position(), {
    invulnerable = barrelConfig.invulnerable, --true
    health = barrelConfig.health, --35
    kickable = barrelConfig.kickable, --true
    killOnReload = barrelConfig.killOnReload --true
  })
  if barrelConfig.smashOnSpawn then --true
    object.smash(true)
  end
end