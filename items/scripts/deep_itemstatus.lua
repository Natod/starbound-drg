require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end

function init()
  deep_init()

  self.itemStatus = {}

  self.maxAmmo = config.getParameter("maxAmmo", 100)
  storage.reserveAmmo = storage.reserveAmmo or self.maxAmmo

end

function update(dt, fireMode, shiftHeld)
  deep_update(dt, fireMode, shiftHeld)

  self.itemStatus.reserveAmmo = storage.reserveAmmo
  self.itemStatus.rAmmoDigits = config.getParameter("reserveAmmoDigits", 3)
  self.itemStatus.rAmmoPos = vec2.sub(activeItem.ownerAimPosition(), mcontroller.position())
  self.itemStatus.rAmmoColor = {200, 200, 200, 200}


  world.sendEntityMessage(activeItem.ownerEntityId(), "deep_changeItemField", self.itemStatus)
end