require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

function init()
  self.thrownObj = config.getParameter("thrownObj", "jeep")
  self.objTags = config.getParameter("objectTags", {})
end

function update(dt)
  
end

function uninit()
  world.spawnVehicle(self.thrownObj, mcontroller.position(), {})
end

function identifyType(query)
  local hasTag = false
  if deep_util.isInTable(query, self.objTags) then hasTag = true end
  
  if hasTag then
    if query == "mineheadDeposit" then
      projectile.die()
    end
  end
  
  return hasTag
end

