require "/scripts/vec2.lua"

local deep_update = update or function() end
local deep_init = init or function() end
local deep_uninit = uninit or function() end

function init()
  deep_init()

  
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
  --updateCursor()
end

function activate(fireMode, shiftHeld)
  if fireMode == "primary" and shiftHeld then
    triggerProjectiles()
  end
end

function update(dt, fireMode, shiftHeld)
  deep_update()


  updateAim()

  storage.fireTimer = math.max(storage.fireTimer - dt, 0)
  --self.recoilTimer = math.max(self.recoilTimer - dt, 0)
  if storage.reserveAmmo > 0 or player.isAdmin() then
    if fireMode == "primary" and not shiftHeld then
      local throwAnimationAngle = math.pi/2.5
      if self.throwPower < self.maxThrowPower then
        self.throwPower = self.throwPower + dt * self.maxThrowPower
        activeItem.setArmAngle(self.throwPower/self.maxThrowPower * throwAnimationAngle)
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
  end

  updateProjectiles()
  updateCursor()
end

function updateCursor()
  if #storage.activeProjectiles > 0 then
    activeItem.setCursor("/cursors/deep/deep_chargeready.cursor")
  else
    if storage.reserveAmmo > 0 then
      activeItem.setCursor("/cursors/deep/deep_crosshair1.cursor")
    else 
      activeItem.setCursor("/cursors/deep/deep_noAmmo2.cursor")
    end
  end
end

function uninit()
  deep_uninit()

  for i, projectile in ipairs(storage.activeProjectiles) do
    world.callScriptedEntity(projectile, "setTarget", nil)
  end
end

function fire()
  if not player.isAdmin() then
    storage.reserveAmmo = math.max(storage.reserveAmmo - 1, 0)
    world.sendEntityMessage(activeItem.ownerEntityId(), "deep_updateAmmoTable", "reserve", self.itemID, storage.reserveAmmo)
  end

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
