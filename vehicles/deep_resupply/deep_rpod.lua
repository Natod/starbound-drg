require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/deep_util.lua"

function init(dt)
  
  vehicle.setDamageTeam({type = "ghostly"})
  animator.setParticleEmitterActive("particleGlow", false)
  vehicle.setInteractive(false)
  mcontroller.applyParameters(self.movementSettings)
  animator.setLightActive("ambientGlow", true)
  
  storage.rackCount = storage.rackCount or 4
  storage.racks = storage.racks or {}

  if storage.rackCount > 0 then
    for i,rack in pairs(storage.racks) do 
      world.sendEntityMessage(rack, "deep_destroyRack")
    end
    storage.racks = {}
    for i=0,(storage.rackCount-1) do
      local ve = world.spawnVehicle("deep_resupply", mcontroller.position(), {
        rackID = string.format("%s",i),
        parentID = entity.id()
      })
      table.insert(storage.racks, ve)
    end
  end
  sb.logInfo(sb.print(storage.rackCount))
  
  if storage.rackCount > 0 then
    vehicle.setPersistent(true)
  else
    vehicle.setPersistent(false)
  end

  message.setHandler("deep_resupplyEmpty", function(messageName, isLocalEntity)
    storage.rackCount = storage.rackCount - 1
  end)

end

function update(dt)
  mcontroller.setXVelocity(0)
end
