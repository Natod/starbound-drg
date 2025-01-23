require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

function init()
  self.thrownObj = config.getParameter("thrownObj", "jeep")
  self.objTags = config.getParameter("objectTags", {})
  self.deposited = false
  message.setHandler("depositableType", depositableType)
end

function update(dt)
  
end

function uninit()
  if not self.deposited then
    world.spawnVehicle(self.thrownObj, mcontroller.position(), {})
  end
end

function identifyType(query)
  local hasTag = false
  if deep_util.isInTable(query, self.objTags) then hasTag = true end
  return hasTag
end

function depositableType()
  self.deposited = true
  projectile.die()
  return self.thrownObj
end

