require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rope.lua"

function init()
  self.fireOffset = config.getParameter("fireOffset")
  self.ropeOffset = config.getParameter("ropeOffset")
  self.ropeVisualOffset = config.getParameter("ropeVisualOffset")
  self.consumeOnUse = config.getParameter("consumeOnUse")
  self.projectileType = config.getParameter("projectileType")
  self.projectileParameters = config.getParameter("projectileParameters")
  self.reelInDistance = config.getParameter("reelInDistance")
  self.reelOutLength = config.getParameter("reelOutLength")
  self.breakLength = config.getParameter("breakLength")
  self.minSwingDistance = config.getParameter("minSwingDistance")
  self.reelSpeed = config.getParameter("reelSpeed")
  self.controlForce = config.getParameter("controlForce")
  self.groundLagTime = config.getParameter("groundLagTime")
  self.rechargeTime = config.getParameter("rechargeTime")

  self.rope = {}
  self.ropeLength = 0
  self.aimAngle = 0
  self.onGround = false
  self.onGroundTimer = 0
  self.facingDirection = 0
  self.projectileId = nil
  self.projectilePosition = nil
  self.anchored = false
  self.previousMoves = {}
  self.previousFireMode = nil
  self.counter = 0
  self.playedSound = true
end

function uninit()
  cancel()
end

function update(dt, fireMode, shiftHeld, moves)
  if self.counter > 0 and not self.projectileId then
    self.counter = self.counter - (1*dt)
  end

  if not self.playedSound and self.counter <= 0 then
    animator.playSound("recharge")
    self.playedSound = true
  end
  
  if fireMode == "primary" and self.previousFireMode ~= "primary" then
    if self.projectileId then
      cancel()
    elseif status.stat("activeMovementAbilities") < 1 and self.counter <= 0 then
      fire()
    end
  end
  self.previousFireMode = fireMode

  self.aimAngle, self.facingDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
  activeItem.setFacingDirection(self.facingDirection)

  trackGround(dt)
  trackProjectile()

  if self.projectileId then
    if world.entityExists(self.projectileId) then
      local position = mcontroller.position()
      local handPosition = vec2.add(position, activeItem.handPosition(self.ropeOffset))

      local newRope
      if #self.rope == 0 then
        newRope = {handPosition, self.projectilePosition}
      else
        newRope = copy(self.rope)
        table.insert(newRope, 1, world.nearestTo(newRope[1], handPosition))
        table.insert(newRope, world.nearestTo(newRope[#newRope], self.projectilePosition))
      end

      windRope(newRope)
      updateRope(newRope)

      if not self.anchored and self.ropeLength > self.reelOutLength then
        cancel()
      end
    else
      cancel()
    end
  end

  if self.ropeLength > self.breakLength then
    cancel()
  end

  if self.anchored then
    self.counter = self.rechargeTime
    self.playedSound = false
    swing(moves, dt, fireMode)
  else
    activeItem.setArmAngle(self.aimAngle)
  end
end

function trackProjectile()
  if self.projectileId then
    if world.entityExists(self.projectileId) then
      local position = mcontroller.position()
      self.projectilePosition = vec2.add(world.distance(world.entityPosition(self.projectileId), position), position)
      if not self.anchored then
        self.anchored = world.callScriptedEntity(self.projectileId, "anchored")
      end
    else
      cancel()
    end
  end
end

function trackGround(dt)
  if mcontroller.onGround() then
    self.onGround = true
    self.onGroundTimer = self.groundLagTime
  else
    self.onGroundTimer = self.onGroundTimer - dt
    if self.onGroundTimer < 0 then
      self.onGround = false
    end
  end
end

function fire()
  cancel()

  local aimVector = vec2.rotate({1, 0}, self.aimAngle)
  aimVector[1] = aimVector[1] * self.facingDirection

  self.projectileId = world.spawnProjectile(
      self.projectileType,
      firePosition(),
      activeItem.ownerEntityId(),
      aimVector,
      false,
      self.projectileParameters
    )

  if self.projectileId then
    animator.playSound("fire")
    status.setPersistentEffects("grapplingHook"..activeItem.hand(), {{stat = "activeMovementAbilities", amount = 0.5}})
  end
end

function cancel()
  if self.projectileId and world.entityExists(self.projectileId) then
    world.callScriptedEntity(self.projectileId, "kill")
  end
  if self.projectileId and self.anchored and self.consumeOnUse then
    item.consume(1)
  end
  self.projectileId = nil
  self.projectilePosition = nil
  self.anchored = false
  updateRope({})
  status.clearPersistentEffects("grapplingHook"..activeItem.hand())
end

function swing(moves, dt, fireMode)
  local canReel = self.ropeLength > self.reelInDistance or world.magnitude(self.rope[2], mcontroller.position()) > self.reelInDistance

  local armAngle = activeItem.aimAngle(self.fireOffset[2], self.rope[2])
  local pullDirection = vec2.withAngle(armAngle)
  activeItem.setArmAngle(self.facingDirection == 1 and armAngle or math.pi - armAngle)
  if fireMode == "primary" then
    status.addEphemeralEffect("nofalldamage",dt)
    if world.magnitude(self.projectilePosition, mcontroller.position()) < self.minSwingDistance then
      --do nothing
      --mcontroller.approachVelocity( {0,0}, 200 )
      --mcontroller.approachXVelocity(0, self.reelSpeed)
      --mcontroller.approachYVelocity(0, self.reelSpeed)
      --mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), 0, self.reelSpeed, true)
      mcontroller.setVelocity({0,0})
    --[[
    elseif self.onGround then
      if (moves.up and canReel) or self.ropeLength > self.reelOutLength then
        mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), self.reelSpeed, self.controlForce, true)
      end
    else
      if moves.down and self.ropeLength < self.reelOutLength then
        mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), -self.reelSpeed, self.controlForce, true)
      elseif moves.up and canReel then
        mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), self.reelSpeed, self.controlForce, true)
      elseif pullDirection[2] > 0 or self.ropeLength > self.reelOutLength then
        mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), 0, self.controlForce, true)
      end

      if moves.jump and not self.previousMoves.jump then
        if not mcontroller.canJump() then
          mcontroller.controlJump(true)
        end
        cancel()
      end
      ]]
    else
      mcontroller.setVelocity({0,0})
      mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), self.reelSpeed, 9999999, true)
      --mcontroller.controlAcceleration({0, (10 * math.sin(vec2.angle(pullDirection))) })

      if moves.jump and not self.previousMoves.jump then
        if not mcontroller.canJump() then
          mcontroller.controlJump(true)
        end
        cancel()
      end
    end
  else
    status.removeEphemeralEffect("nofalldamage")
    cancel()
  end

  self.previousMoves = moves
end

function firePosition()
  local entityPos = mcontroller.position()
  local barrelOffset = activeItem.handPosition(self.fireOffset)
  local barrelPosition = vec2.add(entityPos, barrelOffset)
  local collidePoint = world.lineCollision(entityPos, barrelPosition)
  if collidePoint then
    return vec2.add(entityPos, vec2.mul(barrelOffset, vec2.mag(barrelOffset) - 0.5))
  else
    return barrelPosition
  end
end

function updateRope(newRope)
  local position = mcontroller.position()
  local previousRopeCount = #self.rope
  self.rope = newRope
  self.ropeLength = 0

  activeItem.setScriptedAnimationParameter("ropeOffset", self.ropeVisualOffset)
  for i = 2, #self.rope do
    self.ropeLength = self.ropeLength + world.magnitude(self.rope[i], self.rope[i - 1])
    activeItem.setScriptedAnimationParameter("p" .. i, self.rope[i])
  end
  for i = #self.rope + 1, previousRopeCount do
    activeItem.setScriptedAnimationParameter("p" .. i, nil)
  end
end
