require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end


function init()
  deep_init()

  -- scale damage and calculate energy cost
  self.pType = config.getParameter("projectileType")
  self.pParams = config.getParameter("projectileParameters", {})
  --self.pParams.power = self.pParams.power * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  storage.heat = storage.heat or 0
  storage.overheated = storage.overheated or false



  activeItem.setScriptedAnimationParameter("heat", storage.heat)
  activeItem.setScriptedAnimationParameter("overheated", storage.overheated)
  self.heatRate = config.getParameter("heatRate", 2)
  self.coolRate = config.getParameter("coolRate", 5)
  self.maxHeat = config.getParameter("maxHeat", 20)

  storage.recoverTimestamp = storage.recoverTimestamp or (os.clock() + storage.heat/self.coolRate)
  self.coolTime = config.getParameter("coolTime", 4)

  self.fireOffset = config.getParameter("fireOffset")
  updateAim()

  animator.setAnimationState("gun", "idle")
  world.sendEntityMessage(activeItem.ownerEntityId(), "deep_updateAmmoTable", "maxR", self.itemID, self.maxReserveAmmo)

  self.firing = false
end

function update(dt, fireMode, shiftHeld)
  deep_update()
  
  
  activeItem.setCursor("/cursors/deep/deep_crosshair1.cursor")

  if storage.heat > 0 then
    if storage.recoverTimestamp-os.clock() < (storage.heat/self.coolRate) and fireMode ~= "primary" then
      local oldHeat = storage.heat
      storage.heat = math.max((storage.recoverTimestamp - os.clock())*self.coolRate, 0)
      --deep_util.print(string.format("よかった oldheat: %s, newheat: %s", oldHeat/self.coolRate, storage.heat/self.coolRate))
    end
    --deep_util.print(storage.recoverTimestamp-os.clock())
    storage.recoverTimestamp = os.clock() + storage.heat/self.coolRate
  end

  updateAim()
  if not storage.overheated then
    if storage.heat < self.maxHeat then
      if (storage.reserveAmmo > 0 or player.isAdmin()) and fireMode == "primary" then
        if not player.isAdmin() then
          storage.heat = math.min(storage.heat + dt * self.heatRate, self.maxHeat)
        end
        if self.firing == false then
          self.firing = true
          animator.playSound("fire", -1)
        end
        fire(dt)
      else
        self.firing = false
        animator.stopAllSounds("fire")
        animator.setAnimationState("gun", "idle")
        storage.heat = math.max(storage.heat - dt * self.coolRate, 0)
      end
    else
      storage.overheated = true
      self.firing = false
      animator.stopAllSounds("fire")
    end
  else
    activeItem.setCursor("/cursors/deep/deep_warning2.cursor")
    animator.setAnimationState("gun", "idle")
    storage.heat = math.max(storage.heat - dt * self.coolRate, 0)
    if storage.heat == 0 then
      storage.overheated = false
    end
  end
  activeItem.setScriptedAnimationParameter("heat", storage.heat)
  activeItem.setScriptedAnimationParameter("overheated", storage.overheated)

  if not (storage.reserveAmmo > 0) then
    activeItem.setScriptedAnimationParameter("overheated", true)
    activeItem.setArmAngle(-math.pi*0.15)
    activeItem.setCursor("/cursors/deep/deep_noAmmo2.cursor")
  end

end


function uninit()
  deep_uninit()

end

function fire(dt)
  animator.setAnimationState("gun", "drill", false)
  world.spawnProjectile(
    self.pType,
    firePosition(),
    activeItem.ownerEntityId(),
    aimVector(),
    false,
    self.pParams
  )
  if not player.isAdmin() then
    storage.reserveAmmo = math.max(storage.reserveAmmo - dt*self.ammoConsumptionRate, 0)
    world.sendEntityMessage(activeItem.ownerEntityId(), "deep_updateAmmoTable", "reserve", self.itemID, storage.reserveAmmo)
  end
  --animator.burstParticleEmitter("fireParticles")
  --animator.playSound("fire")
  --self.recoilTimer = config.getParameter("recoilTime", 0.12)
end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
  activeItem.setArmAngle(self.aimAngle)
  activeItem.setFacingDirection(self.aimDirection)
  if storage.overheated then
    activeItem.setArmAngle(-math.pi*0.15)
  end
end

function firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.fireOffset))
end

function aimVector()
  local aimVector = vec2.rotate({1, 0}, self.aimAngle)
  aimVector[1] = aimVector[1] * self.aimDirection
  return aimVector
end
