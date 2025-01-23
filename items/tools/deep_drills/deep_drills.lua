require "/scripts/vec2.lua"

function init()
  -- scale damage and calculate energy cost
  self.pType = config.getParameter("projectileType")
  self.pParams = config.getParameter("projectileParameters", {})
  --self.pParams.power = self.pParams.power * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  storage.heat = storage.heat or 0
  self.heatRate = config.getParameter("heatRate", 2)
  self.coolRate = config.getParameter("coolRate", 5)
  storage.overheated = storage.overheated or false
  self.inv = 1

  self.fireOffset = config.getParameter("fireOffset")
  updateAim()

  storage.fireTimer = storage.fireTimer or 0
  --self.recoilTimer = 0

  storage.activeProjectiles = storage.activeProjectiles or {}
  --updateCursor()
end

function activate(fireMode, shiftHeld)
  if fireMode == "primary" and shiftHeld then
    triggerProjectiles()
  end
end

function update(dt, fireMode, shiftHeld)
  

  storage.fireTimer = math.max(storage.fireTimer - dt, 0)
  --self.recoilTimer = math.max(self.recoilTimer - dt, 0)

  local recoiling = recoiling or false

  if not storage.overheated then
    updateAim()
    if storage.heat < 20 then
      if fireMode == "primary" then
        storage.heat = math.min(storage.heat + dt * self.heatRate, 20)
        fire(dt)
        activeItem.setRecoil(recoiling)
        recoiling = not recoiling
      else
        storage.heat = math.max(storage.heat - dt * self.coolRate, 0)
      end
    else
      storage.overheated = true
    end
  else
    activeItem.setArmAngle(math.pi*0.15)
    storage.heat = math.max(storage.heat - dt * self.coolRate, 0)
    if storage.heat == 0 then
      storage.overheated = false
    end
  end

  


  updateProjectiles()
  --updateCursor()
end

function updateCursor()
  if #storage.activeProjectiles > 0 then
    activeItem.setCursor("/cursors/chargeready.cursor")
  else
    activeItem.setCursor("/cursors/reticle0.cursor")
  end
end

function uninit()
  for i, projectile in ipairs(storage.activeProjectiles) do
    world.callScriptedEntity(projectile, "setTarget", nil)
  end
end

function fire(dt)
  world.spawnProjectile(
    self.pType,
    firePosition(),
    activeItem.ownerEntityId(),
    aimVector(),
    false,
    self.pParams
  )
  self.inv = -self.inv 
  animator.translateTransformationGroup("rotate",{self.inv*dt,0})
  --animator.burstParticleEmitter("fireParticles")
  --animator.playSound("fire")
  --self.recoilTimer = config.getParameter("recoilTime", 0.12)
end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
  activeItem.setArmAngle(self.aimAngle)
  activeItem.setFacingDirection(self.aimDirection)
end

function updateProjectiles()
  local newProjectiles = {}
  for i, projectile in ipairs(storage.activeProjectiles) do
    if world.entityExists(projectile) then
      newProjectiles[#newProjectiles + 1] = projectile
    end
  end
  storage.activeProjectiles = newProjectiles
end

function triggerProjectiles()
  if #storage.activeProjectiles > 0 then
    animator.playSound("trigger")
  end
  for i, projectile in ipairs(storage.activeProjectiles) do
    world.callScriptedEntity(projectile, "trigger")
  end
end

function firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.fireOffset))
end

function aimVector()
  local aimVector = vec2.rotate({1, 0}, self.aimAngle + sb.nrand(config.getParameter("inaccuracy", 0), 0))
  aimVector[1] = aimVector[1] * self.aimDirection
  return aimVector
end
