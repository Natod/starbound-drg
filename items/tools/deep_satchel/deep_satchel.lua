require "/scripts/vec2.lua"

function init()
  -- scale damage and calculate energy cost
  self.pType = config.getParameter("projectileType")
  self.pParams = config.getParameter("projectileParameters", {})
  self.pParams.power = self.pParams.power * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  self.pParams.speed = 0
  self.energyPerShot = config.getParameter("energyUsage")
  self.maxThrowPower = config.getParameter("maxThrowPower", 30)
  self.throwPower = 0

  self.fireOffset = config.getParameter("fireOffset")
  updateAim()

  storage.fireTimer = storage.fireTimer or 0
  --self.recoilTimer = 0

  storage.activeProjectiles = storage.activeProjectiles or {}
  updateCursor()
end

function activate(fireMode, shiftHeld)
  if fireMode == "primary" and shiftHeld then
    triggerProjectiles()
  end
end

function update(dt, fireMode, shiftHeld)
  updateAim()

  storage.fireTimer = math.max(storage.fireTimer - dt, 0)
  --self.recoilTimer = math.max(self.recoilTimer - dt, 0)

  if fireMode == "primary" and not shiftHeld then
    --if storage.fireTimer <= 0
    local throwAnimationAngle = math.pi/2.5
    if self.throwPower < self.maxThrowPower then
      self.throwPower = self.throwPower + dt * self.maxThrowPower
      --animator.rotateTransformationGroup("rotate", -dt*throwAnimationAngle, {0.5,3})
      activeItem.setArmAngle(self.throwPower/self.maxThrowPower * throwAnimationAngle)
      --animator.translateTransformationGroup("rotate", {dt/3,-dt/4})
      if self.throwPower >= self.maxThrowPower then
        animator.playSound("recharge")
      end
    end

  else
    activeItem.setArmAngle(-math.pi/2)
    if self.throwPower > 0.0 then
      if not world.lineCollision(mcontroller.position(),firePosition()) then
        storage.fireTimer = config.getParameter("fireTime", 1.0)
        fire()
        animator.playSound("fire")
      end

      self.throwPower = 0
    end
  end

  --activeItem.setRecoil(self.recoilTimer > 0)

  updateProjectiles()
  updateCursor()
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

function fire()
  self.pParams.speed = self.throwPower
  self.pParams.powerMultiplier = activeItem.ownerPowerMultiplier()
  local projectileId = world.spawnProjectile(
      self.pType,
      firePosition(),
      activeItem.ownerEntityId(),
      aimVector(),
      false,
      self.pParams
    )
  if projectileId then
    storage.activeProjectiles[#storage.activeProjectiles + 1] = projectileId
  end
  --animator.burstParticleEmitter("fireParticles")
  animator.playSound("fire")
  --self.recoilTimer = config.getParameter("recoilTime", 0.12)
end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
  --activeItem.setArmAngle(self.aimAngle)
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
