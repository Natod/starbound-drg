require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/status.lua"

function init()
  --[[
  local blockTable =
  {
    [4803] = "wet",
  }
  --]] 
  --[[
  player.giveEssentialItem("beamaxe","deep_pickaxe")
  player.giveEssentialItem("wiretool","deep_flaregun")
  player.giveEssentialItem("painttool","deep_platformgun")
  player.makeTechAvailable("deep_flare")
  player.enableTech("deep_flare")
  player.equipTech("deep_flare")
  ]]
end

function update(dt)
end

function checkBlocks()
  local matID = world.material({mcontroller.xPosition(), mcontroller.yPosition()}, "foreground")
  return matID
end