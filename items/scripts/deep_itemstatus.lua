require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end

function init()
  deep_init()

  self.itemStatus = {}
  self.itemID = config.getParameter("itemName")

  self.maxReserveAmmo = config.getParameter("maxReserveAmmo", 500)
  storage.reserveAmmo = storage.reserveAmmo or self.maxReserveAmmo
  --if the maxAmmo is 0 it can't be reloaded (eg drills)
  self.maxAmmo = config.getParameter("maxAmmo", 100)
  if self.maxAmmo ~= 0 then
    storage.loadedAmmo = storage.loadedAmmo or self.maxAmmo
  end

  self.ammoConsumptionRate = config.getParameter("ammoConsumptionRate", 1)
  self.promises = {}
  

end

function update(dt, fireMode, shiftHeld)
  deep_update(dt, fireMode, shiftHeld)


  --send the itemStatus table to the player localAnimator script to be rendered
  --
  table.insert(self.promises, world.sendEntityMessage(activeItem.ownerEntityId(), "deep_getAmmoTable", "reserve", self.itemID))  
  for i,promise in pairs(self.promises) do
    if promise:finished() then
      if promise:succeeded() then
        storage.reserveAmmo = promise:result()
        --deep_util.print(storage.reserveAmmo)
      else
        sb.logInfo(string.format("Item %s did not recieve a response. Error: %s", self.itemID, promise:error()))
      end
      self.promises[i] = nil
    end
  end

  self.itemStatus.reserveAmmo = storage.reserveAmmo
  self.itemStatus.rAmmoDigits = config.getParameter("reserveAmmoDigits", 3)
  self.itemStatus.rAmmoPos = vec2.add(vec2.sub(activeItem.ownerAimPosition(), mcontroller.position()), {-0.5, (self.maxAmmo == 0) and -1 or -1})
  self.itemStatus.rAmmoColor = {255, 255, 255, 200} 
  --world.sendEntityMessage(activeItem.ownerEntityId(), "deep_updateAmmoTable", "reserve", self.itemID, storage.reserveAmmo)

  if self.maxAmmo ~= 0 then
    self.itemStatus.loadedAmmo = storage.loadedAmmo
    self.itemStatus.lAmmoDigits = config.getParameter("reserveAmmoDigits", 3)
    self.itemStatus.lAmmoPos = vec2.add(vec2.sub(activeItem.ownerAimPosition(), mcontroller.position()), {-0.5, 1})
    self.itemStatus.lAmmoColor = {255, 255, 255, 200}
    --world.sendEntityMessage(activeItem.ownerEntityId(), "deep_updateAmmoTable", "loaded", self.itemID, storage.loadedAmmo)
  end

  world.sendEntityMessage(activeItem.ownerEntityId(), "deep_changeItemField", self.itemStatus)
end

function uninit()
  deep_uninit()

  --clears the active itemStatus table so it doesn't render anything
  world.sendEntityMessage(activeItem.ownerEntityId(), "deep_changeItemField", {})
end