require "/scripts/vec2.lua"
require "/scripts/deep_util.lua"

function init()
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
end

function update(dt, fireMode, shiftHeld)

  
  
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
      if fireMode == "primary" then
        
        storage.heat = math.min(storage.heat + dt * self.heatRate, self.maxHeat)
        fire(dt)
      else
        animator.setAnimationState("gun", "idle")
        storage.heat = math.max(storage.heat - dt * self.coolRate, 0)
      end
    else
      storage.overheated = true
    end
  else
    animator.setAnimationState("gun", "idle")
    storage.heat = math.max(storage.heat - dt * self.coolRate, 0)
    if storage.heat == 0 then
      storage.overheated = false
    end
  end
  activeItem.setScriptedAnimationParameter("heat", storage.heat)
  activeItem.setScriptedAnimationParameter("overheated", storage.overheated)

end


function uninit()
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
