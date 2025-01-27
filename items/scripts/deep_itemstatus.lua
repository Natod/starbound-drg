require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end

function init()
  deep_init()

  self.itemStatus = {}

  self.maxReserveAmmo = config.getParameter("maxReserveAmmo", 500)
  storage.reserveAmmo = storage.reserveAmmo or self.maxReserveAmmo
  --if the maxAmmo is 0 it can't be reloaded (eg drills)
  self.maxAmmo = config.getParameter("maxAmmo", 100)
  if self.maxAmmo ~= 0 then
    storage.loadedAmmo = storage.loadedAmmo or self.maxAmmo
  end

  self.ammoConsumptionRate = config.getParameter("ammoConsumptionRate", 1)

end

function update(dt, fireMode, shiftHeld)
  deep_update(dt, fireMode, shiftHeld)


  --send the itemStatus table to the player localAnimator script to be rendered
  self.itemStatus.reserveAmmo = storage.reserveAmmo
  self.itemStatus.rAmmoDigits = config.getParameter("reserveAmmoDigits", 3)
  self.itemStatus.rAmmoPos = vec2.add(vec2.sub(activeItem.ownerAimPosition(), mcontroller.position()), {-0.5, (self.maxAmmo == 0) and -1 or -1})
  self.itemStatus.rAmmoColor = {200, 200, 200, 200} 

  if self.reloadable then
    self.itemStatus.loadedAmmo = storage.loadedAmmo
    self.itemStatus.lAmmoDigits = config.getParameter("reserveAmmoDigits", 3)
    self.itemStatus.lAmmoPos = vec2.add(vec2.sub(activeItem.ownerAimPosition(), mcontroller.position()), {-0.5, 1})
    self.itemStatus.lAmmoColor = {200, 200, 200, 200}
  end

  world.sendEntityMessage(activeItem.ownerEntityId(), "deep_changeItemField", self.itemStatus)
end

function uninit()
  deep_uninit()

  --clears the active itemStatus table so it doesn't render anything
  world.sendEntityMessage(activeItem.ownerEntityId(), "deep_changeItemField", {})
end